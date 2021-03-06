module NauLdap

  # Класс для взаимодействия с ActiveDirectory
  class ActiveDirectory < Ldap

    # Одинаковые атрибуты для создания всех учетных записей в ActiveDirectory
    AD_STATIC_ATTRIBUTES = {
      objectClass:    %w[top person organizationalPerson user],
      accountExpires: '9223372036854775807',
      shadowInactive: '0',
      countryCode:    '0',
      codePage:       '0'
    }.freeze

    # Метод записи в ActiveDirectory.
    # @note Важное замечание по созданию записей в ActiveDirectory:
    #
    #   * Все данные по учетной записи можно создать сразу
    #   * Пароль и разрешения добавляются к уже созданной учетной записи
    #   * Пароль должен быть в кодировке microsoft
    #
    # @param [Hash] attrs строгий набор параметров, одинаковый для всех методов записи и обновления
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError]
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    def write(attrs)
      valid? attrs
      ldap       = connect
      dn         = set_dn(attrs)
      attributes = set_attributes(attrs)
      pwd        = microsoft_encode_password(attrs['password'])
      ldap.add(dn: dn, attributes: attributes)
      ldap.add_attribute(dn, 'unicodePwd', pwd)
      ldap.replace_attribute(dn, 'userAccountControl', '512')

      get_ldap_response(ldap)
    end

    # Метод обновления данных.
    # @param [Hash] attrs строгий набор параметров, одинаковый для всех методов записи и обновления (see REQUIRED_ATTRIBUTES)
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError] в случае ошибок взаимодейстия с LDAP
    # @raise [NauLdap::AccountNotFound] в случае, если не найдена учетная запись с данным hrID
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    def update(attrs)
      valid?(attrs) { REQUIRED_ATTRIBUTES.reject { |a| a == 'password' } }

      args = transform_arguments(attrs)
      ldap = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry = ldap.search(base: base, filter: filter, return_result: true).first

      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ops = []
      args.reject { |k| k == :cn }.each { |k, v| ops << [:replace, k, [v]] }
      ldap.modify(dn: entry['dn'].first, operations: ops)
      ldap.rename(
        olddn: entry['dn'].first,
        newrdn: "CN=#{args[:cn]}",
        delete_attributes: true,
        new_superior: base
      )

      get_ldap_response(ldap)
    end

    # Изменение пароля в ActiveDirectory
    # @param [Hash{String => String}] attrs необходимы два аргумента:
    #
    #   * hrID => Value
    #   * password => Value
    #
    # @return [Hash]
    # @raise [NauLdap::LdapInteractionError] в случае ошибок взаимодейстия с LDAP
    # @raise [NauLdap::AccountNotFound] в случае, если не найдена учетная запись с данным hrID
    # @raise [NauLdap::InvalidAttributeError] в случае невалидности переданных атрибутов
    def change_password(attrs)
      raise NauLdap::InvalidAttributeError, "Invalid arguments: #{attrs}" unless attrs.key?('hrID') && attrs.key?('password')

      ldap   = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry  = ldap.search(base: base, filter: filter, return_result: true).first

      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :unicodePwd, microsoft_encode_password(attrs['password']))

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

      ldap.replace_attribute(entry['dn'].first, :userAccountControl, '514')
      ldap.replace_attribute(entry['dn'].first, :shadowInactive, '1')
      get_ldap_response(ldap)
    end

    private

    def hr_id
      'employeeID'
    end

    def base
      App.settings.ad_base
    end

    def login_attribute
      'sAMAccountName'
    end

    def static_attributes
      AD_STATIC_ATTRIBUTES.merge(objectCategory: "CN=Person,CN=Schema,CN=Configuration,DC=#{App.settings.dc_1},DC=#{App.settings.dc_2}")
    end

    def dynamic_attributes(attrs)
      transform_arguments(attrs)
    end

    def microsoft_encode_password(pwd)
      ret = ""
      pwd = "\"" + pwd + "\""
      pwd.length.times { |i| ret += "#{pwd[i]}\000" }
      ret
    end

    def bind_dn
      App.settings.ad_bind_dn
    end

    def set_dn(attrs)
      "cn=#{attrs['lastName']} #{attrs['firstName']} #{attrs['middleName']},#{base}"
    end

    def transform_arguments(attrs)
      {
        sAMAccountName:             attrs['uid'],
        sn:                         attrs['lastName'],
        givenName:                  attrs['firstName'],
        extensionAttribute13:       attrs['middleName'],
        telephoneNumber:            attrs['telephoneNumber'],
        ipPhone:                    attrs['telephoneNumber'],
        mobile:                     attrs['mobile'],
        l:                          attrs['city'],
        physicalDeliveryOfficeName: attrs['physicalDeliveryOfficeName'],
        title:                      attrs['position'],
        department:                 attrs['department'],
        employeeID:                 attrs['hrID'],
        displayName:                "#{attrs['lastName']} #{attrs['firstName']} #{attrs['middleName']}",
        cn:                         "#{attrs['lastName']} #{attrs['firstName']} #{attrs['middleName']}",
        mail:                       "#{attrs['uid']}@naumen.ru",
        userPrincipalName:          "#{attrs['uid']}@#{App.settings.dc_1}.#{App.settings.dc_2}",
        description:                "#{attrs['position']} #{attrs['department']}"
      }
    end
  end
end
