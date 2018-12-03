module NauLdap
  class Error < StandardError; end

  class InvalidAttributeError < Error; end

  class AccountNotFound < Error; end

  class LdapInteractionError < Error; end
end