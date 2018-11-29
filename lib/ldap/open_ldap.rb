module NauLdap
  class OpenLdap < Ldap

    def write(attrs)
      valid? attrs
      ldap       = connect
      attributes = set_attributes(attrs)
      dn         = set_dn(attributes)
      ldap.add(dn: dn, attributes: attributes)
      get_ldap_response(ldap)
    end

    # @param [Hash] attrs Атрибут(-ы), который(-е) необходимо изменить
    # Required attributes:
    #
    #   * employeeNumber
    #   * uid
    #   * givenName
    #   * sn
    #   * cn
    #   * telephoneNumber
    #   * employeeNumber
    #   * l
    #   *
    #   * physicalDeliveryOfficeName
    #   * title
    def update(attrs)
      valid? attrs
      args = transform_arguments(attrs)
      ldap = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      if entry.nil?
        raise NauLdap::AccountNotFound.new("Запись с id: '#{attrs['hrID']}' не найдена!")
      else
        ops = []
        args.each { |k, v| ops << [:replace, k, [v]] }
        ldap.modify(dn: entry['dn'].first, operations: ops)
        get_ldap_response(ldap)
      end
    end

    def change_password(employee_number, pwd)
      ldap = connect
      filter = Net::LDAP::Filter.eq('employeeNumber', employee_number)
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{employee_number}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userPassword, pwd)
    end

    def deactivate_account(employee_number)
      ldap = connect
      filter = Net::LDAP::Filter.eq('employeeNumber', employee_number)
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{employee_number}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userPassword, Random.new_seed)
      ldap.replace_attribute(entry['dn'].first, :shadowInactive, '1')
    end
  end
end