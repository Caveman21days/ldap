module NauLdap

  # Общий класс ошибок NauLdap
  class Error < StandardError; end

  # Класс ошибок для невалидных атрибутов
  class InvalidAttributeError < Error; end

  # Класс ошибок для ненайденных по hrID аккаунтов
  class AccountNotFound < Error; end

  # Класс общих ошибок при взаимодействии с LDAP
  class LdapInteractionError < Error; end
end