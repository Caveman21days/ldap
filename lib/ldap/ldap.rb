module NauLdap
  class Ldap

    # Обязательные атрибуты. Ключи хэша атрибутов в любом методе должны быть из этого списка!
    # Включают в себя:
    #
    #   * hrID - ID пользователя в HR
    #   * uid - логин в HR
    #   * lastName - фамилия
    #   * firstName - имя
    #   * middleName - отчество
    #   * city - город
    #   * telephoneNumber - внутренний номер телефона
    #   * mobile - мобильный номер телефона сотрудника
    #   * physicalDeliveryOfficeName - адресс офиса
    #   * position - должность
    #   * department - отдел
    #   * password - пароль (мин. 8 символов, верхний и нижний регистры, цифры)
    REQUIRED_ATTRIBUTES = %w[
      hrID uid lastName firstName middleName city telephoneNumber mobile physicalDeliveryOfficeName position department password
    ].freeze

    # @param [Hash] args включает в себя:
    #
    #   * host - берется из конфигов
    #   * password - берется из конфигов
    #   * port - 389 NoSSL by default / 636 SSL
    #   * encryption - simple_tls by default
    #   * base - берется из конфигов
    #   * version - 3 by default
    def initialize(args)
      @host       = args['host']
      @password   = args['password']
      @port       = args['port'] || 389
      @encryption = args['encryption'] || :simple_tls
      @base       = args['base'] || ''
      @version    = args['version'] || 3
    end

    # Соединение с LDAP
    # @return [Net::LDAP] возвращает эксемпляр соединения с LDAP
    # @raise [Net::LDAP::Error] при неудачной попытке соединения с LDAP
    def connect
      ldap = Net::LDAP.new(
        host: @host,
        port: @port,
        encryption: @encryption,
        base: @base,
        auth: {
          method: :simple,
          username: bind_dn,
          password: @password
        }
      )
      ldap.bind ? ldap : get_ldap_response(ldap)
    end

    # Проверка наличия логина в LDAP
    # @param [Hash{String => String}] attrs логин, который нужно проверить
    # @return [Hash] статус запроса и информация о занятости логина
    def check_login(attrs)
      ldap = connect
      logins = []
      ldap.search(base: search_treebase, attributes: login_attribute, return_result: false) do |entry|
        logins << entry[login_attribute].first
      end
      {
        status: ldap.get_operation_result.message,
        data: logins.include?(attrs['uid']) ? 'Логин занят!' : 'Логин свободен!'
      }
    end

    private

    def get_ldap_response(ldap)
      if ldap.get_operation_result.code.zero?
        {
          status: ldap.get_operation_result.message,
          details: {
            self.class => "Response Code: #{ldap.get_operation_result.code}, Message: #{ldap.get_operation_result.message}"
          }
        }
      else
        raise NauLdap::LdapInteractionError, "Response Code: #{ldap.get_operation_result.code}, Message: #{ldap.get_operation_result.message}"
      end
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

    # Checks the validity of the attributes passed
    # @param [Array] attrs
    # @return [Boolean]
    def valid?(attrs)
      @invalid_keys ||= []
      valid_attrs = attrs.reject { |k| attrs[k].nil? || attrs[k] == '' }
      REQUIRED_ATTRIBUTES.each { |k| @invalid_keys << k unless valid_attrs.key?(k) }
      @invalid_keys.empty? ? true : raise(NauLdap::InvalidAttributeError, @invalid_keys)
    end
  end
end
