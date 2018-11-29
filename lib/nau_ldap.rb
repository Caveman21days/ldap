require 'net/ldap'
require 'russian'

require File.dirname(__FILE__) + '/ldap/ldap'
require File.dirname(__FILE__) + '/ldap/errors'
require File.dirname(__FILE__) + '/ldap/active_directory'
require File.dirname(__FILE__) + '/ldap/open_ldap'
require File.dirname(__FILE__) + '/ldap/open_ldap_1'
require File.dirname(__FILE__) + '/ldap/open_ldap_2'


module NauLdap
  #  В файл /etc/hosts
  #  добавить строку: 10.105.0.121 tempxdc1.nau.res
  #  и в скриптах прописывать подключение уже к tempxdc1.nau.res

  attrs = {
    'uid'                        => 'kotkidach',
    'lastName'                   => 'Откидач',
    'firstName'                  => 'Кирилл',
    'middleName'                 => 'Витальевич',
    'telephoneNumber'            => '13378',
    'mobile'                     => '+79090047523',
    'city'                       => 'Екатеринбург',
    'physicalDeliveryOfficeName' => 'Татищева 49а',
    'position'                   => 'Инженер',
    'department'                 => '3.2.4 Группа разработки Екатеринбург',
    'password'                   => 'qwerTY123',
    'hrID'                       => '123123'
  }
  ###################################
  #      РАБОЧАЯ ЗАПИСЬ В АД        #
  ###################################
  ldap = NauLdap::ActiveDirectory.new(
    'host'       => 'tempxdc1.nau.res',
    'port'       => 636,
    'password'   => 'Zaqwsx147852',
    'encryption' => :simple_tls,
    'version'    => 3
  )

  # p ldap.write(attrs)

  # p ldap.update(attrs)

  p ldap.check_login('kotkidach')

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
  ldap = NauLdap::OpenLdap1.new(
    'host'       => 'ldap-test.naumen.ru',
    'port'       => 389,
    'password'   => 'YRp4NS6YfYAWNrlzKV',
    'encryption' => ''
  )

  # ldap.write(attrs)

  # p ldap.update(attrs)

  # p ldap.check_login('kotkidach')

  # p ldap.change_password('123123', '12312aaaaa12335566')

  # p ldap.deactivate_account('123123')
  ###################################
end