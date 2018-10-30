require 'russian'
require 'net/ldap'

require File.dirname(__FILE__) + '/lib/ldap/service'
require File.dirname(__FILE__) + '/lib/ldap/active_directory'
require File.dirname(__FILE__) + '/lib/ldap/open_ldap_1'
require File.dirname(__FILE__) + '/lib/ldap/open_ldap_2'


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
  #   host: 'tempxdc1.nau.res',
  #   port: 636,
  #   password: 'Zaqwsx147852',
  #   encryption: :simple_tls,
  #   version: 3
  # )
  #
  # ldap.write(
  #   uid: 'kotkidach',
  #   sn: 'Откидач',
  #   givenName: 'Кирилл',
  #   secondName: 'Витальевич',
  #   phoneNumber: '1337',
  #   mobile: '+79090047523',
  #   l: 'Екатеринбург',
  #   physicalDeliveryOfficeName: 'Татищева 49а',
  #   title: 'Инженер',
  #   department: '3.2.4 Группа разработки Екатеринбург',
  #   password: 'qwerT1234'
  # )

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
  #   host: 'ldapadmin-test.naumen.ru',
  #   port: 389,
  #   password: 'YRp4NS6YfYAWNrlzKV',
  #   encryption: '',
  # )
  # ldap.write(
  #   uid: 'aaawerty',
  #   givenName: 'Кирилл',
  #   secondName: 'Витальевич',
  #   sn: 'Откидач',
  #   l: 'Екатеринбург',
  #   physicalDeliveryOfficeName: 'Татищева 49а',
  #   title: 'Инженер',
  #   phoneNumber: '2718',
  #   uidNumber: '55555555555'
  # )
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
  ldap = NauLdap::OpenLdap1.new(
    host: 'ldap-test.naumen.ru',
    port: 389,
    password: 'YRp4NS6YfYAWNrlzKV',
    encryption: ''
  )
  p ldap.write(
    uid: 'aaasdf',
    givenName: 'test',
    secondName: 'test',
    sn: 'test',
    l: 'Екатеринбург',
    physicalDeliveryOfficeName: 'Татищева 49а',
    title: 'Инженер',
    phoneNumber: '123456',
    uidNumber: '1018'
  )
  ###################################
end