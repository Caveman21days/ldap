module NauLdap

  # Класс для работы с OpenLdap.
  # Имеет различия с ActiveDirectory в алгоритмах работы методов записи, обновления и деактивации учетных записей
  class OpenLdap < Ldap

    # Метод записи в OpenLdap
    # @param [Hash] attrs строгий набор параметров, одинаковый для всех методов записи и обновления
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError] в случае ошибок взаимодействия с LDAP
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    # @raise [NauLdap::AccountNotFound] в случае, если не найдена учетная запись с данным hrID
    def write(attrs)
      valid? attrs
      ldap       = connect
      attributes = set_attributes(attrs)
      dn         = set_dn(attributes)
      ldap.add(dn: dn, attributes: attributes)

      get_ldap_response(ldap)
    end

    # Метод обновления данных в OpenLdap
    # @param [Hash] attrs строгий набор параметров, одинаковый для всех методов записи и обновления
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError] в случае ошибок взаимодейстия с LDAP
    # @raise [NauLdap::AccountNotFound] в случае, если не найдена учетная запись с данным hrID
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    def update(attrs)
      valid? attrs
      args = transform_arguments(attrs)
      ldap = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ops = []
      args.each { |k, v| ops << [:replace, k, [v]] }
      ldap.modify(dn: entry['dn'].first, operations: ops)

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
      filter = Net::LDAP::Filter.eq('employeeNumber', attrs['hrID'])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
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
      filter = Net::LDAP::Filter.eq('employeeNumber', attrs['hrID'])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userPassword, md5_password(Random.new_seed))
      ldap.replace_attribute(entry['dn'].first, :shadowInactive, '1')

      get_ldap_response(ldap)
    end

    private

    def transform_arguments(_attrs)
      false
    end

    def md5_password(pwd)
      Net::LDAP::Password.generate(:md5, pwd.to_s)
    end
  end
end