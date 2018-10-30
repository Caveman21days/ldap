module NauLdap
  class ActiveDirectory < Service

    BIND_AD_DN = 'CN=Администратор,CN=Users,DC=Nau,DC=res'.freeze

    SEARCH_TREE_BASE_AD = "OU=People,OU=Naumen,DC=Nau,DC=res".freeze

    AD_STATIC_ATTRIBUTES = {
      objectClass: %w[top person organizationalPerson user],
      objectCategory: 'CN=Person,CN=Schema,CN=Configuration,DC=Nau,DC=res',
      accountExpires: '9223372036854775807',
      shadowInactive: '0',
      countryCode: '0',
      codePage: '0'
    }.freeze

    def write(attrs)
      ldap = connect
      dn = set_dn(sn: attrs[:sn], givenName: attrs[:givenName], secondName: attrs[:secondName])
      attributes = set_attributes(attrs)
      ldap.add(dn: dn, attributes: attributes)
      pwd = microsoft_encode_password(attrs[:password])
      ldap.add_attribute(dn, 'unicodePwd', pwd)
      ldap.replace_attribute(dn, 'userAccountControl', "512")
    end

    private

    def search_treebase
      SEARCH_TREE_BASE_AD
    end

    def login_attribute
      'sAMAccountName'
    end

    def write_dynamic_attributes(attrs)
      {
        sn:                         attrs[:sn],
        givenName:                  attrs[:givenName],
        extensionAttribute13:       attrs[:secondName],
        displayName:                "#{attrs[:sn]} #{attrs[:givenName]} #{attrs[:secondName]}",
        cn:                         "#{attrs[:sn]} #{attrs[:givenName]} #{attrs[:secondName]}",
        telephoneNumber:            attrs[:phoneNumber],
        ipPhone:                    attrs[:phoneNumber],
        mobile:                     attrs[:mobile],
        mail:                       "#{attrs[:uid]}@naumen.ru",
        sAMAccountName:             attrs[:uid],
        userPrincipalName:          "#{attrs[:uid]}@Nau.res",
        l:                          attrs[:l],
        physicalDeliveryOfficeName: attrs[:physicalDeliveryOfficeName],
        title:                      attrs[:title],
        department:                 attrs[:department],
        description:                "#{attrs[:title]} #{attrs[:department]}"
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
      "cn=#{attrs[:sn]} #{attrs[:givenName]} #{attrs[:secondName]},OU=People,OU=Naumen,DC=Nau,DC=res"
    end

    def write_static_attributes
      AD_STATIC_ATTRIBUTES
    end
  end
end
