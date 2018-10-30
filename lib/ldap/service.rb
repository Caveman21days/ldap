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

    def check_login(login)
      ldap = connect
      treebase = search_treebase
      logins = []
      ldap.search(base: treebase, attributes: login_attribute, return_result: false) do |entry|
        logins << entry[login_attribute].first
      end
      logins.include?(login)
    end

    def get_ldap_response(ldap)
      msg = "Response Code: #{ldap.get_operation_result.code}, Message: #{ldap.get_operation_result.message}"
      raise msg unless ldap.get_operation_result.code == '0'
    end

    private

    def search_treebase
      false
    end

    def login_attribute
      false
    end

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

    def set_attributes(attrs)
      write_dynamic_attributes(attrs).merge(write_static_attributes)
    end

    def get_uidNumbers
      ldap = connect
      treebase = search_treebase
      uids = [2000]
      ldap.search(base: treebase, attributes: "uidNumber", return_result: false) do |entry|
        uids << entry[:uidNumber].first.to_i if entry[:uidNumber].first.to_i >= 2000
      end
      uids.sort
    end

    def set_uidNumber
      uids = get_uidNumbers
      (0...uids.length).each do |n|
        return uids[n] + 1 if n == uids.length - 1
        return(uids[n] + 1) if uids[n + 1] - uids[n] > 0
      end
    end
  end
end
