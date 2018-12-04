require File.dirname(__FILE__) + '/ldap/ldap'
require File.dirname(__FILE__) + '/ldap/errors'
require File.dirname(__FILE__) + '/ldap/active_directory'
require File.dirname(__FILE__) + '/ldap/open_ldap'
require File.dirname(__FILE__) + '/ldap/open_ldap_1'
require File.dirname(__FILE__) + '/ldap/open_ldap_2'

# Для подключения по 636 порту с использованием ssl для ActiveDirectory необходимо выполнить следущее:
#
#   * В файл /etc/hosts добавить строку: 10.105.0.121 tempxdc1.nau.res
#   * В скриптах прописывать подключение к tempxdc1.nau.res
#
# Чтобы подключиться к ldaps://xdc1-test.naumen.ru/ нужно на компьютере скачать сертификаты:
#
#   * `wget https://download.naumen.ru/upload/IT/Naumen_Exchange_Root_CA.crt -O /usr/share/ca-certificates/Naumen_Exchange_Root_CA.crt`
#   * `wget https://download.naumen.ru/upload/IT/nau.res_RootCA.crt -O /usr/share/ca-certificates/nau.res_RootCA.crt`
#   * Установить их: `dpkg-reconfigure ca-certificates`
#     (ask -> отметить звездочками новые сертификаты)
#   * Если не поможет, то добавить опцию TLS_REQCERT в конфиг, так чтобы возвращалось:
#     `grep -i TLS_REQCERT /etc/ldap/ldap.conf` - `TLS_REQCERT never` и перезагрузить
module NauLdap
  # Обработчик запросов API
  class RequestHandler

    # @param [Hash] settings хэш данных для подключений, данные берутся из конфигурации окружения
    def initialize(settings)
      @ad_host      = settings[:ad_host]
      @ad_password  = settings[:ad_password]
      @ol1_host     = settings[:ol1_host]
      @ol1_password = settings[:ol1_password]
      @ol2_host     = settings[:ol2_host]
      @ol2_password = settings[:ol2_password]
    end

    # Создает подключения к трем разным LDAP.
    # Параметры подключения находятся в конфигах Sinatra в файле '../config.ru'
    # @return [Array] возвращает список подключений
    def connections
      @connections ||= [
        NauLdap::ActiveDirectory.new(
          'host'       => @ad_host,
          'port'       => 636,
          'password'   => @ad_password,
          'encryption' => :simple_tls,
          'version'    => 3
        ),
        NauLdap::OpenLdap1.new(
          'host'       => @ol1_host,
          'port'       => 636,
          'password'   => @ol1_password,
          'encryption' => :simple_tls,
          'version'    => 3
        ),
        NauLdap::OpenLdap2.new(
          'host'       => @ol2_host,
          'port'       => 636,
          'password'   => @ol2_password,
          'encryption' => :simple_tls,
          'version'    => 3
        )
      ]
    end

    # Вызывает переданный метод у трех экземпляров подключения
    # @param [Method] method метод, который требуется выполнить
    # @param [Hash] args аргументы для метода
    # @return [Hash] результат работы метода 3 трех разных LDAP
    def method_missing(method, *args)
      responses = []
      connections.each do |conn|
        responses << conn.send(method, *args)
      end
      responses.reduce Hash.new, :merge
    end
  end
end
