require File.dirname(__FILE__) + '/ldap/ldap'
require File.dirname(__FILE__) + '/ldap/errors'
require File.dirname(__FILE__) + '/ldap/active_directory'
require File.dirname(__FILE__) + '/ldap/open_ldap'
require File.dirname(__FILE__) + '/ldap/open_ldap_1'
require File.dirname(__FILE__) + '/ldap/open_ldap_2'

module NauLdap

  # Обработчик запросов API
  class RequestHandler

    # Создает подключения к трем разным LDAP.
    # Параметры подключения находятся в конфигах Sinatra в файле '../config.ru'
    # @return [Array] возвращает список подключений
    def connections
      @connections ||= [
        NauLdap::ActiveDirectory.new(
          'host'       => App.settings.ad_host,
          'port'       => 636,
          'password'   => App.settings.ad_password,
          'encryption' => :simple_tls,
          'version'    => 3
        ),
        NauLdap::OpenLdap1.new(
          'host'       => App.settings.ol1_host,
          'port'       => 636,
          'password'   => App.settings.ol1_password,
          'encryption' => :simple_tls,
          'version'    => 3
        ),
        NauLdap::OpenLdap2.new(
          'host'       => App.settings.ol2_host,
          'port'       => 636,
          'password'   => App.settings.ol2_password,
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
