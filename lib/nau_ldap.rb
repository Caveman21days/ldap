require 'russian'
require 'net/ldap'

require File.dirname(__FILE__) + '/ldap/service'
require File.dirname(__FILE__) + '/ldap/errors'
require File.dirname(__FILE__) + '/ldap/active_directory'
require File.dirname(__FILE__) + '/ldap/open_ldap_1'
require File.dirname(__FILE__) + '/ldap/open_ldap_2'


module NauLdap
  #  В файл /etc/hosts
  #  добавить строку: 10.105.0.121 tempxdc1.nau.res
  #  и в скриптах прописывать подключение уже к tempxdc1.nau.res
  ###################################
  #      РАБОЧАЯ ЗАПИСЬ В АД        #
  ###################################
  #  необходимые для записи параметры:
  #  uid                         - Логин
  #  givenName                   - Имя
  #  secondName                  - Отчество
  #  sn                          - Фамилия
  #  l                           - Город
  #  physicalDeliveryOfficeName  - Адрес офиса
  #  title                       - Должность
  #  phoneNumber                 - Внутренний номер
  #  mobile                      - Мобильный телефон (optional)
  #  department                  - 3.2.4 Группа разработки Екатеринбург
  #  password                    - Пароль
  #####################################
  # ldap = NauLdap::ActiveDirectory.new(
  #   'host'       => 'tempxdc1.nau.res',
  #   'port'       => 636,
  #   'password'   => 'Zaqwsx147852',
  #   'encryption' => :simple_tls,
  #   'version'    => 3
  # )

  # p ldap.write(
  #   'sAMAccountName'             => 'kotkidach',
  #   'sn'                         => 'Откидач',
  #   'givenName'                  => 'Кирилл',
  #   'extensionAttribute13'       => 'Витальевич',
  #   'telephoneNumber'            => '13378',
  #   'mobile'                     => '+79090047523',
  #   'l'                          => 'Екатеринбург',
  #   'physicalDeliveryOfficeName' => 'Татищева 49а',
  #   'title'                      => 'Инженер',
  #   'department'                 => '3.2.4 Группа разработки Екатеринбург',
  #   'unicodePwd'                 => 'qwerT1234123',
  #   'employeeID'                 => '123123'
  # )

  # p ldap.update('employeeID' => '123123', 'mail' => '1aaa23@1aaa23.h')

  # p ldap.deactivate_account('123123')

  # p ldap.change_password('123123', 'qwerT1234qq')


  ###################################
  #      РАБОЧАЯ ЗАПИСЬ В OL2       #
  ###################################
  # необходимые для записи параметры:
  #  uid                         - Логин
  #  givenName                   - Имя
  #  secondName                  - Отчество
  #  sn                          - Фамилия
  #  l                           - Город
  #  physicalDeliveryOfficeName  - Адрес офиса
  #  title                       - Должность
  #  phoneNumber                 - Внутренний номер
  #  uidNumber                   - Уникальный id в ldap
  ###################################
  # ldap = NauLdap::OpenLdap2.new(
  #   'host'       => 'ldapadmin-test.naumen.ru',
  #   'port'       => 389,
  #   'password'   => 'YRp4NS6YfYAWNrlzKV',
  #   'encryption' => ''
  # )

  # ldap.write(
  #   'uid'                        => 'aaawerty',
  #   'givenName'                  => 'Кирилл',
  #   'sn'                         => 'Откидач',
  #   'cn'                         => 'Откидач Кирилл Витальевич',
  #   'l'                          => 'Санкт-Петербург',
  #   'physicalDeliveryOfficeName' => 'Татищева 49а',
  #   'title'                      => 'Инженер',
  #   'telephoneNumber'            => '2718',
  #   'employeeNumber'             => '123123',
  #   'userPassword'               => '1111111111'
  # )

  # p ldap.update('employeeNumber' => '123123', 'mail' => '1aaa23@1aaa23.h')

  # p ldap.check_login('aaawertyasd')

  # p ldap.change_password('123123', '12312aaaaa12335566')



  ###################################
  #      РАБОЧАЯ ЗАПИСЬ В OL1       #
  ###################################
  # необходимые для записи параметры:
  #  uid                         - Логин
  #  givenName                   - Имя
  #  secondName                  - Отчество
  #  sn                          - Фамилия
  #  l                           - Город
  #  physicalDeliveryOfficeName  - Адрес офиса
  #  title                       - Должность
  #  phoneNumber                 - Внутренний номер
  #  uidNumber                   - Уникальный id в ldap (УБРАТЬ ОТСЮДА, ГЕНЕРИТСЯ САМ)
  ###################################
  # ldap = NauLdap::OpenLdap1.new(
  #   'host'       => 'ldap-test.naumen.ru',
  #   'port'       => 389,
  #   'password'   => 'YRp4NS6YfYAWNrlzKV',
  #   'encryption' => ''
  # )

  # ldap.write(
  #   'uid'                        => 'aawerty',
  #   'givenName'                  => 'aaaa',
  #   'sn'                         => 'aaaa',
  #   'cn'                         => 'aaaa aaaa aaaa',
  #   'l'                          => 'Екатеринбург',
  #   'physicalDeliveryOfficeName' => 'Татищева 49а',
  #   'title'                      => 'Инженер',
  #   'telephoneNumber'            => '21234567',
  #   'employeeNumber'             => '123123111',
  #   'userPassword'               => '11111111'
  #   # 'asd' => '123'
  # )

  # ldap.check_login('kotkidach')

  # p ldap.update('employeeNumber' => '123123111', 'mail' => '1aaa23@1aaa23.h')

  # p ldap.change_password('123123111', '12312aaaaa12335566')
  ###################################
end