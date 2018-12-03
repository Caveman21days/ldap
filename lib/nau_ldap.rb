require File.dirname(__FILE__) + '/ldap/ldap'
require File.dirname(__FILE__) + '/ldap/errors'
require File.dirname(__FILE__) + '/ldap/active_directory'
require File.dirname(__FILE__) + '/ldap/open_ldap'
require File.dirname(__FILE__) + '/ldap/open_ldap_1'
require File.dirname(__FILE__) + '/ldap/open_ldap_2'

#  В файл /etc/hosts
#  добавить строку: 10.105.0.121 tempxdc1.nau.res
#  и в скриптах прописывать подключение уже к tempxdc1.nau.res

module NauLdap
  class RequestHandler

    def initialize(settings)
      @ad_host      = settings[:ad_host]
      @ad_password  = settings[:ad_password]
      @ol1_host     = settings[:ol1_host]
      @ol1_password = settings[:ol1_password]
      @ol2_host     = settings[:ol2_host]
      @ol2_password = settings[:ol2_password]
    end

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
          'port'       => 389,
          'password'   => @ol1_password,
          'encryption' => ''
        ),
        NauLdap::OpenLdap2.new(
          'host'       => @ol2_host,
          'port'       => 389,
          'password'   => @ol2_password,
          'encryption' => ''
        )
      ]
    end

    def method_missing(method, *args)
      responses = []
      connections.each do |conn|
        responses << conn.send(method, *args)
      end
      responses.reduce Hash.new, :merge
    end
  end
end

  # attrs = {
  #   'uid'                        => 'kotkidach',
  #   'lastName'                   => 'Откидач',
  #   'firstName'                  => 'Кирилл',
  #   'middleName'                 => 'Витальевич',
  #   'telephoneNumber'            => '13378',
  #   'mobile'                     => '+79090047523',
  #   'city'                       => 'Екатеринбург',
  #   'physicalDeliveryOfficeName' => 'Татищева 49а',
  #   'position'                   => 'Инженер',
  #   'department'                 => '3.2.4 Группа разработки Екатеринбург',
  #   'password'                   => 'qwerTY123',
  #   'hrID'                       => '123123'
  # }
  ###################################
  #      РАБОЧАЯ ЗАПИСЬ В АД        #
  ###################################
  # ldap = NauLdap::ActiveDirectory.new(
  #   'host'       => 'tempxdc1.nau.res',
  #   'port'       => 636,
  #   'password'   => 'Zaqwsx147852',
  #   'encryption' => :simple_tls,
  #   'version'    => 3
  # )

  # p ldap.write(attrs)
  # p ldap.update(attrs)
  # p ldap.check_login('kotkidach')
  # p ldap.change_password('123123', 'qwerT1234qq')
  # p ldap.deactivate_account('123123')

  ###################################
  #      РАБОЧАЯ ЗАПИСЬ В OL2       #
  ###################################
  # ldap = NauLdap::OpenLdap2.new(
  #   'host'       => 'ldapadmin-test.naumen.ru',
  #   'port'       => 389,
  #   'password'   => 'YRp4NS6YfYAWNrlzKV',
  #   'encryption' => ''
  # )

  # p ldap.write(attrs)
  # p ldap.update(attrs)
  # p ldap.check_login('kotkidach')
  # p ldap.change_password('123123', '12312aaaaa12335566')
  # p ldap.deactivate_account('123123')

  ###################################
  #      РАБОЧАЯ ЗАПИСЬ В OL1       #
  ###################################
  # ldap = NauLdap::OpenLdap1.new(
  #   'host'       => 'ldap-test.naumen.ru',
  #   'port'       => 389,
  #   'password'   => 'YRp4NS6YfYAWNrlzKV',
  #   'encryption' => ''
  # )

  # ldap.write(attrs)
  # p ldap.update(attrs)
  # p ldap.check_login('kotkidach')
  # p ldap.change_password('123123', '12312aaaaa12335566')
  # p ldap.deactivate_account('123123')

  ###################################
