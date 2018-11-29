module NauLdap
  class OpenLdap2 < OpenLdap

    BIND_OL2_DN = 'uid=hradmin,ou=sysusers,ou=People,dc=naumen,dc=ru'.freeze

    SEARCH_TREE_BASE_OL2 = "ou=People,dc=naumen,dc=ru".freeze

    OL2_STATIC_ATTRIBUTES = {
      objectClass: %w[inetOrgPerson posixAccount shadowAccount top naumenAccount],
      gidNumber: '2000',
      loginShell: '/usr/bin/passwd',
      shadowInactive: '0',
      shadowWarning: '0',
      shadowFlag: '0',
      shadowMin: '0',
      shadowMax: '99999',
      shadowExpire: '99999'
    }.freeze

    private

    def login_attribute
      'uid'
    end

    def search_treebase
      SEARCH_TREE_BASE_OL2
    end

    def bind_dn
      BIND_OL2_DN
    end

    def set_dn(attrs)
      "uid=#{attrs[:uid]},#{set_city(attrs[:l])},ou=People,dc=naumen,dc=ru"
    end

    def translit_str(str)
      Russian.translit(str)
    end

    def set_city(city)
      case city.to_s
      when 'Екатеринбург'
        'ou=ekb'
      when 'Москва'
        'ou=msk'
      when 'Санкт-Петербург'
        'ou=spb'
      when 'Челябинск'
        'ou=chel'
      when 'Тверь'
        'ou=twr'
      when 'Севастополь'
        'ou=sev'
      else
        'ou=external'
      end
    end

    def static_attributes
      OL2_STATIC_ATTRIBUTES
    end

    def dynamic_attributes(attrs)
      transform_arguments(attrs)
    end

    def hr_id
      'employeeNumber'
    end

    def transform_arguments(attrs)
      {
        uid:                        attrs['uid'],
        displayName:                attrs['uid'],
        givenName:                  attrs['firstName'],
        sn:                         attrs['lastName'],
        l:                          attrs['city'],
        physicalDeliveryOfficeName: attrs['physicalDeliveryOfficeName'],
        title:                      attrs['position'],
        telephoneNumber:            attrs['telephoneNumber'],
        employeeNumber:             attrs['hrID'],
        userPassword:               attrs['password'],
        mail:                       "#{attrs['uid']}@naumen.ru",
        homeDirectory:              "/home/#{attrs['uid']}",
        uidNumber:                  set_uidNumber.to_s,
        cn:                         "#{attrs['lastName']} #{attrs['firstName']} #{attrs['middleName']}",
        naumenName:                 translit_str(attrs['firstName']),
        naumenLastName:             translit_str(attrs['lastName']),
        naumenEMail:                "#{attrs['uid']}@naumen.ru",
        naumenPhone:                attrs['telephoneNumber']
      }
    end
  end
end