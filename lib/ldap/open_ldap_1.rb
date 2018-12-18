module NauLdap
  class OpenLdap1 < OpenLdap

    # Одинаковые атрибуты для создания всех учетных записей в OpenLdap1
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

    private

    def base
      App.settings.ol1_base
    end

    def bind_dn
      App.settings.ol1_bind_dn
    end

    def set_dn(attrs)
      "uid=#{attrs[:uid]},#{base}"
    end

    def static_attributes
      OL1_STATIC_ATTRIBUTES
    end

    def dynamic_attributes(attrs)
      transform_arguments(attrs)
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
        userPassword:               md5_password(attrs['password']),
        mail:                       "#{attrs['uid']}@naumen.ru",
        homeDirectory:              "/home/#{attrs['uid']}",
        uidNumber:                  set_uidNumber.to_s,
        cn:                         "#{attrs['lastName']} #{attrs['firstName']} #{attrs['middleName']}"
      }
    end
  end
end