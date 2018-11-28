module NauLdap
  class OpenLdap2 < Service

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

    OL2_DYNAMIC_ATTRIBUTE_KEYS = %w[
      uid displayName givenName sn cn mail telephoneNumber
      employeeNumber l physicalDeliveryOfficeName naumenName
      naumenLastName naumenEMail naumenPhone title userPassword
    ].freeze

    def change_password(employee_number, pwd)
      update('employeeNumber' => employee_number, 'userPassword' => pwd)
    end

    def deactivate_account(employee_number)
      update('employeeNumber' => employee_number, 'userPassword' => Random.seed, 'shadowInactive' => '1')
    end

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
      "uid=#{attrs['uid']},#{map_city(attrs['l'])},ou=People,dc=naumen,dc=ru"
    end

    def static_attributes
      OL2_STATIC_ATTRIBUTES
    end

    def translit_str(str)
      Russian.translit(str)
    end

    def map_city(city)
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

    def dynamic_attributes(attrs)
      {
        uid:                        attrs['uid'],
        displayName:                attrs['uid'],
        givenName:                  attrs['givenName'],
        sn:                         attrs['sn'],
        cn:                         attrs['cn'],
        mail:                       "#{attrs['uid']}@naumen.ru",
        l:                          attrs['l'],
        physicalDeliveryOfficeName: attrs['physicalDeliveryOfficeName'],
        title:                      attrs['title'],
        telephoneNumber:            attrs['telephoneNumber'],
        homeDirectory:              "/home/#{attrs['uid']}",
        naumenName:                 translit_str(attrs['givenName']),
        naumenLastName:             translit_str(attrs['sn']),
        naumenEMail:                "#{attrs['uid']}@naumen.ru",
        naumenPhone:                attrs['telephoneNumber'],
        uidNumber:                  set_uidNumber.to_s,
        employeeNumber:             attrs['employeeNumber']
      }
    end

    def hr_id
      'employeeNumber'
    end

    def valid_attribute_keys
      OL2_DYNAMIC_ATTRIBUTE_KEYS
    end
  end
end