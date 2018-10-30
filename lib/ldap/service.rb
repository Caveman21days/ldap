module NauLdap
  class Service
    attr_reader :host, :password, :port, :encryption, :base, :version

    def initialize(args)
      @host       = args[:host]
      @password   = args[:password]
      @port       = args[:port] || 389
      @encryption = args[:encryption] || :simple_tls
      @base       = args[:base] || ''
      @version    = args[:version] || 3
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
      ldap = connect
      dn = set_dn(attrs)
      attributes = set_attributes(attrs)
      ldap.add(dn: dn, attributes: attributes)
    end

    def set_attributes(attrs)
      write_dynamic_attributes(attrs).merge(write_static_attributes)
    end

    def get_ldap_response(ldap)
      msg = "Response Code: #{ldap.get_operation_result.code}, Message: #{ldap.get_operation_result.message}"
      raise msg unless ldap.get_operation_result.code == '0'
    end

    def get_login
      # TODO: Getting login value (existed of not)
    end

    private

    def set_dn(attrs)
      false
    end

    def bind_dn
      false
    end

    def write_dynamic_attributes(attrs)
      false
    end

    def write_static_attributes
      false
    end

  end
end
