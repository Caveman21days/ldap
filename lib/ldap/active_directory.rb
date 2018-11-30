module NauLdap
  class ActiveDirectory < Ldap

    BIND_AD_DN = 'CN=Администратор,CN=Users,DC=Nau,DC=res'.freeze

    SEARCH_TREE_BASE_AD = "OU=People,OU=Naumen,DC=Nau,DC=res".freeze

    AD_STATIC_ATTRIBUTES = {
      objectClass:    %w[top person organizationalPerson user],
      objectCategory: 'CN=Person,CN=Schema,CN=Configuration,DC=Nau,DC=res',
      accountExpires: '9223372036854775807',
      shadowInactive: '0',
      countryCode:    '0',
      codePage:       '0'
    }.freeze

    def write(attrs)
      valid? attrs
      ldap = connect
      dn = set_dn(attrs)
      attributes = set_attributes(attrs)
      pwd = microsoft_encode_password(attrs['password'])
      ldap.add(dn: dn, attributes: attributes)
      ldap.add_attribute(dn, 'unicodePwd', pwd)
      ldap.replace_attribute(dn, 'userAccountControl', '512')
      get_ldap_response(ldap)
    end

    def update(attrs)
      valid? attrs
      args = transform_arguments(attrs)
      ldap = connect
      filter = Net::LDAP::Filter.eq('employeeID', args[:employeeID])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      if entry.nil?
        raise NauLdap::AccountNotFound.new("Запись с id: '#{args[:employeeID]}' не найдена!")
      else
        ops = []
        args.reject { |k| k == :cn }.each { |k, v| ops << [:replace, k, [v]] }
        ldap.modify(dn: entry['dn'].first, operations: ops)
        ldap.rename(
          olddn: entry['dn'].first,
          newrdn: "CN=#{args[:cn]}",
          delete_attributes: true,
          new_superior: "OU=People,OU=Naumen,DC=Nau,DC=res"
        )
        get_ldap_response(ldap)
      end
    end

    def change_password(employee_id, pwd)
      ldap = connect
      filter = Net::LDAP::Filter.eq('employeeID', employee_id)
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{employee_id}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :unicodePwd, microsoft_encode_password(pwd))
      get_ldap_response(ldap)
    end

    def deactivate_account(employee_id)
      ldap = connect
      filter = Net::LDAP::Filter.eq('employeeID', employee_id)
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{employee_id}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userAccountControl, '514')
      get_ldap_response(ldap)
    end

    private

    def search_treebase
      SEARCH_TREE_BASE_AD
    end

    def login_attribute
      'sAMAccountName'
    end

    def static_attributes
      AD_STATIC_ATTRIBUTES
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
      BIND_AD_DN
    end

    def set_dn(attrs)
      "cn=#{attrs['lastName']} #{attrs['firstName']} #{attrs['middleName']},OU=People,OU=Naumen,DC=Nau,DC=res"
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
        userPrincipalName:          "#{attrs['uid']}@Nau.res",
        description:                "#{attrs['position']} #{attrs['department']}"
      }
    end
  end
end
