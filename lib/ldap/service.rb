module NauLdap
  class Service
    attr_reader :host, :password, :port, :encryption, :base, :version

    def initialize(args)
      @host       = args['host']
      @password   = args['password']
      @port       = args['port'] || 389
      @encryption = args['encryption'] || :simple_tls
      @base       = args['base'] || ''
      @version    = args['version'] || 3
    end

    def connect
      ldap = Net::LDAP.new(
        host: host,
        port: port,
        encryption: encryption,
        base: base,
        auth: {
          method: :simple,
          username: bind_dn,
          password: password
        }
      )
      ldap.bind ? ldap : get_ldap_response(ldap)
    end

    def write(attrs)
      if valid? attrs.keys
        ldap = connect
        dn   = set_dn(attrs)
        attributes = set_attributes(attrs)
        ldap.add(dn: dn, attributes: attributes)
        get_ldap_response(ldap)
      end
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
      if valid? attrs.keys
        ldap = connect
        filter = Net::LDAP::Filter.eq(hr_id, attrs[hr_id])
        entry = ldap.search(base: search_treebase, filter: filter, return_result: true).first
        if entry.nil?
          raise NauLdap::AccountNotFound.new("Запись с id: '#{attrs[hr_id]}' не найдена!")
        else
          ops = []
          attrs.each { |k, v| ops << [:replace, k, [v]] }
          ldap.modify(dn: entry['dn'].first, operations: ops)
          get_ldap_response(ldap)
        end
      end
    end

    def check_login(login)
      ldap = connect
      logins = []
      ldap.search(base: search_treebase, attributes: login_attribute, return_result: false) do |entry|
        logins << entry[login_attribute].first
      end
      logins.include?(login)
    end

    private

    def get_ldap_response(ldap)
      msg = "Response Code: #{ldap.get_operation_result.code}, Message: #{ldap.get_operation_result.message}"
      raise msg unless ldap.get_operation_result.code == 0
    end

    # Path for searching
    # @return [String]
    def search_treebase
      false
    end

    # uid= / ou=
    # @return [String]
    def login_attribute
      false
    end

    # @param [Hash]
    # @return [String]
    def set_dn(attrs)
      false
    end

    # DN for setting up connection
    # (example: 'uid=hradmin,ou=users,dc=naumen,dc=ru')
    # @return [String]
    def bind_dn
      false
    end

    # Attributes that change depending on the account
    # @param [Hash] attrs attributes for account
    # @return {Hash{Symbol => String}}
    def dynamic_attributes(attrs)
      false
    end

    # Default attributes for every kind of ldap
    # @return {Hash{Symbol => String}}
    def static_attributes
      false
    end

    # Concat attrs
    # @param [Hash{String: String}] attrs изменяющиеся атрибуты для учетки
    # @return [Hash{String => String}]
    def set_attributes(attrs)
      dynamic_attributes(attrs).merge(static_attributes)
    end

    #  Find all uid numbers which bt 2000
    # @return [Array]
    def get_uidNumbers
      ldap = connect
      treebase = search_treebase
      uids = [2000]
      ldap.search(base: treebase, attributes: 'uidNumber', return_result: false) do |entry|
        uids << entry[:uidNumber].first.to_i if entry[:uidNumber].first.to_i > 2000
      end
      uids.sort
    end

    # Set uid for account (automatically found)
    def set_uidNumber
      uids = get_uidNumbers
      (0...uids.length).each do |n|
        return uids[n] + 1 if n == uids.length - 1
        return(uids[n] + 1) if uids[n + 1] - uids[n] > 0
      end
    end

    def hr_id
      false
    end

    def valid_attribute_keys
      false
    end

    # Checks the validity of the attributes passed
    # @param [Array] keys
    # @return [Boolean]
    def valid?(keys)
      invalid_keys = []
      keys.each { |k| invalid_keys << k unless valid_attribute_keys.include?(k) }
      invalid_keys.empty? ? true : raise(NauLdap::InvalidAttributeError, invalid_keys)
    end
  end
end
