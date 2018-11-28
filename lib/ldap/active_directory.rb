module NauLdap
  class ActiveDirectory < Service

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

    AD_DYNAMIC_ATTRIBUTE_KEYS = %w[
      sn givenName extensionAttribute13 telephoneNumber ipPhone unicodePwd
      mobile sAMAccountName l physicalDeliveryOfficeName description userAccountControl
      title department employeeID displayName cn mail userPrincipalName
    ].freeze

    def write(attrs)
      if valid? attrs.keys
        ldap = connect
        dn = set_dn(sn: attrs['sn'], givenName: attrs['givenName'], extensionAttribute13: attrs['extensionAttribute13'])
        attributes = set_attributes(attrs)
        ldap.add(dn: dn, attributes: attributes)
        pwd = microsoft_encode_password(attrs['unicodePwd'])
        ldap.add_attribute(dn, 'unicodePwd', pwd)
        ldap.replace_attribute(dn, 'userAccountControl', '512')
        get_ldap_response(ldap)
      end
    end

    def change_password(employee_id, pwd)
      update('employeeID' => employee_id, 'unicodePwd' => microsoft_encode_password(pwd))
    end

    def deactivate_account(employee_id)
      update('employeeID' => employee_id, 'userAccountControl' => '514')
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
      {
        sn:                         attrs['sn'],
        givenName:                  attrs['givenName'],
        extensionAttribute13:       attrs['extensionAttribute13'],
        telephoneNumber:            attrs['telephoneNumber'],
        ipPhone:                    attrs['telephoneNumber'],
        mobile:                     attrs['mobile'],
        sAMAccountName:             attrs['sAMAccountName'],
        l:                          attrs['l'],
        physicalDeliveryOfficeName: attrs['physicalDeliveryOfficeName'],
        title:                      attrs['title'],
        department:                 attrs['department'],
        employeeID:                 attrs['employeeID'],
        displayName:                "#{attrs['sn']} #{attrs['givenName']} #{attrs['extensionAttribute13']}",
        cn:                         "#{attrs['sn']} #{attrs['givenName']} #{attrs['extensionAttribute13']}",
        mail:                       "#{attrs['sAMAccountName']}@naumen.ru",
        userPrincipalName:          "#{attrs['sAMAccountName']}@Nau.res",
        description:                "#{attrs['title']} #{attrs['department']}"
      }
    end

    def microsoft_encode_password(pwd)
      ret = ""
      pwd = "\"" + pwd + "\""
      pwd.length.times { |i| ret += "#{pwd[i..i]}\000" }
      ret
    end

    def bind_dn
      BIND_AD_DN
    end

    def set_dn(attrs)
      "cn=#{attrs[:sn]} #{attrs[:givenName]} #{attrs[:extensionAttribute13]},OU=People,OU=Naumen,DC=Nau,DC=res"
    end

    def hr_id
      'employeeID'
    end

    def valid_attribute_keys
      AD_DYNAMIC_ATTRIBUTE_KEYS
    end
  end
end
