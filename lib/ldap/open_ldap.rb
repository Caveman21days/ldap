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
    def update(attrs)
      valid? attrs
      args = transform_arguments(attrs)
      ldap = connect
      filter = Net::LDAP::Filter.eq(hr_id, attrs['hrID'])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ops = []
      args.each { |k, v| ops << [:replace, k, [v]] }
      ldap.modify(dn: entry['dn'].first, operations: ops)

      get_ldap_response(ldap)
    end

    def change_password(attrs)
      raise NauLdap::InvalidAttributeError, "Invalid arguments: #{attrs}" unless attrs.key?('hrID') && attrs.key?('password')

      ldap = connect
      filter = Net::LDAP::Filter.eq('employeeNumber', attrs['hrID'])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userPassword, attrs['password'])

      get_ldap_response(ldap)
    end

    def deactivate_account(attrs)
      raise NauLdap::InvalidAttributeError, "Invalid arguments: #{attrs}" unless attrs.key?('hrID')

      ldap = connect
      filter = Net::LDAP::Filter.eq('employeeNumber', attrs['hrID'])
      entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
      raise NauLdap::AccountNotFound, "Запись с id: '#{attrs['hrID']}' не найдена!" if entry.nil?

      ldap.replace_attribute(entry['dn'].first, :userPassword, Random.new_seed)
      ldap.replace_attribute(entry['dn'].first, :shadowInactive, '1')

      get_ldap_response(ldap)
    end

    private

    def transform_arguments(_attrs)
      false
    end
  end
end