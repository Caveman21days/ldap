module NauLdap
  class OpenLdap1 < Service

    OL1_STATIC_ATTRIBUTES = {
      objectClass: %w[inetOrgPerson posixAccount shadowAccount top],
      loginShell: '/usr/bin/passwd',
      shadowInactive: '0',
      shadowWarning: '0',
      shadowFlag: '0',
      shadowMin: '0',
      shadowMax: '99999',
      shadowExpire: '99999',
      gidNumber: '57925'
    }.freeze

    BIND_OL1_DN = 'uid=hradmin,ou=users,dc=naumen,dc=ru'.freeze

    def write(attrs)
      ldap = connect
      dn = set_dn(uid: attrs[:uid])
      attributes = set_attributes(attrs)
      ldap.add(dn: dn, attributes: attributes)
    end

    def get_uidNumbers
      
    end

    def bind_dn
      BIND_OL1_DN
    end

    def set_dn(attrs)
      "uid=#{attrs[:uid]},ou=users,dc=naumen,dc=ru"
    end

    def write_dynamic_attributes(attrs)
      {
        uid:                        attrs[:uid],
        displayName:                attrs[:uid],
        givenName:                  attrs[:givenName],
        sn:                         attrs[:sn],
        cn:                         "#{attrs[:sn]} #{attrs[:givenName]} #{attrs[:secondName]}",
        mail:                       "#{attrs[:uid]}@naumen.ru",
        l:                          attrs[:l],
        physicalDeliveryOfficeName: attrs[:physicalDeliveryOfficeName],
        title:                      attrs[:title],
        telephoneNumber:            attrs[:phoneNumber],
        homeDirectory:              "/home/users/#{attrs[:uid]}",
        uidNumber:                  attrs[:uidNumber] # SDELAT' METOD!!!
      }
    end

    def write_static_attributes
      OL1_STATIC_ATTRIBUTES
    end
  end
end