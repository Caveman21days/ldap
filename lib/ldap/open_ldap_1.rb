module NauLdap
  class OpenLdap1 < Service

    BIND_OL1_DN = 'uid=hradmin,ou=users,dc=naumen,dc=ru'.freeze

    SEARCH_TREE_BASE_OL1 = "ou=users,dc=naumen,dc=ru".freeze

    OL1_STATIC_ATTRIBUTES = {
      objectClass:    %w[inetOrgPerson posixAccount shadowAccount top],
      loginShell:     '/usr/bin/passwd',
      shadowInactive: '0',
      shadowWarning:  '0',
      shadowFlag:     '0',
      shadowMin:      '0',
      shadowMax:      '99999',
      shadowExpire:   '99999',
      gidNumber:      '57925'
    }.freeze

    OL1_DYNAMIC_ATTRIBUTE_KEYS = %w[
      uid displayName givenName sn cn mail telephoneNumber
      employeeNumber l physicalDeliveryOfficeName title userPassword
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
      SEARCH_TREE_BASE_OL1
    end

    def bind_dn
      BIND_OL1_DN
    end

    def set_dn(attrs)
      "uid=#{attrs['uid']},ou=users,dc=naumen,dc=ru"
    end

    def static_attributes
      OL1_STATIC_ATTRIBUTES
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
        homeDirectory:              "/home/users/#{attrs['uid']}",
        uidNumber:                  set_uidNumber.to_s,
        employeeNumber:             attrs['employeeNumber'],
        userPassword:               attrs['userPassword']
      }
    end

    def hr_id
      'employeeNumber'
    end

    def valid_attribute_keys
      OL1_DYNAMIC_ATTRIBUTE_KEYS
    end
  end
end