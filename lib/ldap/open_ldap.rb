module NauLdap

  # Класс для работы с OpenLdap.
  # Имеет различия с ActiveDirectory в алгоритмах работы методов записи, обновления и деактивации учетных записей
  class OpenLdap < Ldap

    # Метод записи в OpenLdap
    # @param [Hash] attrs строгий набор параметров, одинаковый для всех методов записи и обновления
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError]  в случае ошибок взаимодействия с LDAP
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    # @raise [NauLdap::AccountNotFound]       в случае, если не найдена учетная запись с данным hrID
    def write(attrs)
      valid? attrs
      ldap       = connect
      attributes = set_attributes(attrs)
      dn         = set_dn(attributes)
      ldap.add(dn: dn, attributes: attributes)

      get_ldap_response(ldap)
    end

    # Метод обновления данных.
    # @param [Hash] attrs строгий набор параметров, одинаковый для всех методов записи и обновления (see REQUIRED_ATTRIBUTES)
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError]  в случае ошибок взаимодейстия с LDAP
    # @raise [NauLdap::AccountNotFound]       в случае, если не найдена учетная запись с данным hrID
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    def update(attrs)
      valid?(attrs) { REQUIRED_ATTRIBUTES.reject { |a| a == 'password' } }
      args = transform_arguments(attrs)
      ldap = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry = ldap.search(base: base, filter: filter, return_result: true).first

      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ops = []

      new_rdn      = "uid=#{args[login_attribute.to_sym]}"
      new_superior = set_dn(args).match('[^,]*,(.*)')[1]
      args.each { |k, v| ops << [:replace, k, [v]] }
      new_dn = new_rdn + ',' + new_superior

      ldap.rename(
        olddn: entry['dn'].first,
        newrdn: new_rdn,
        delete_attributes: true,
        new_superior: new_superior
      )
      ldap.modify(dn: new_dn, operations: ops)

      get_ldap_response(ldap)
    end

    # Изменение пароля в OpenLdap
    # @param [Hash{String => String}] attrs необходимы два аргумента:
    #
    #   * hrID[String] => Value[String]
    #   * password[String] => Value[String]
    #
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError] в случае ошибок взаимодейстия с LDAP
    # @raise [NauLdap::AccountNotFound] в случае, если не найдена учетная запись с данным hrID
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    def change_password(attrs)
      raise NauLdap::InvalidAttributeError, "Invalid arguments: #{attrs}" unless attrs.key?('hrID') && attrs.key?('password')

      ldap = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry = ldap.search(base: base, filter: filter, return_result: true).first

      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userPassword, md5_password(attrs['password']))

      get_ldap_response(ldap)
    end

    # Деактивация учетной записи
    # @param [Hash{String => String}] attrs необходима лишь одна пара "ключ-значение": 'hrID[String]' => Value[String]
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError] в случае ошибок взаимодейстия с LDAP
    # @raise [NauLdap::AccountNotFound] в случае, если не найдена учетная запись с данным hrID
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    def deactivate_account(attrs)
      raise NauLdap::InvalidAttributeError, "Invalid arguments: #{attrs}" unless attrs.key?('hrID')

      ldap = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry = ldap.search(base: base, filter: filter, return_result: true).first

      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userPassword, md5_password(Random.new_seed))
      ldap.replace_attribute(entry['dn'].first, :shadowInactive, '1')

      get_ldap_response(ldap)
    end

    private

    #  Find all uid numbers which bt 2000
    # @return [Array]
    def get_uidNumbers
      ldap     = connect
      treebase = base
      uids     = [2000]
      ldap.search(base: treebase, attributes: 'uidNumber', return_result: false) do |entry|
        uids << entry[:uidNumber].first.to_i if entry[:uidNumber].first.to_i > 2000
      end
      uids.sort
    end

    # Set uid for account (automatically found)
    def set_uidNumber
      uids = get_uidNumbers
      (0...uids.length).each do |n|
        return uids[n] + 1 if n == uids.length - 1
        return(uids[n] + 1) if uids[n + 1] - uids[n] > 0
      end
    end

    def md5_password(pwd)
      Net::LDAP::Password.generate(:md5, pwd.to_s)
    end

    def login_attribute
      'uid'
    end

    def hr_id
      'employeeNumber'
    end
  end
end