module NauLdap
  class Error < StandardError; end

  class InvalidAttributeError < Error; end

  class AccountNotFound < Error; end
end