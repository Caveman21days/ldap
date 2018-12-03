require_relative './lib/nau_ldap'
require 'sinatra'
require 'json'

class App < Sinatra::Base

  post '/write' do
    response = response_handler { write JSON.parse(request.body.read) }

    body response
  end

  post '/update' do
    response = response_handler { update JSON.parse(request.body.read) }

    body response
  end

  post'/change_password' do
    response = response_handler { change_password JSON.parse(request.body.read) }

    body response
  end

  post '/deactivate_account' do
    response = response_handler { deactivate_account JSON.parse(request.body.read) }

    body response
  end

  post '/check_login' do
    response = response_handler { check_login JSON.parse(request.body.read) }

    body response
  end

  helpers do
    def write(attrs)
      NauLdap::RequestHandler.new(connection_settings).write(attrs)
    end

    def update(attrs)
      NauLdap::RequestHandler.new(connection_settings).update(attrs)
    end

    def change_password(attrs)
      NauLdap::RequestHandler.new(connection_settings).change_password(attrs)
    end

    def deactivate_account(attrs)
      NauLdap::RequestHandler.new(connection_settings).deactivate_account(attrs)
    end

    def check_login(attrs)
      NauLdap::RequestHandler.new(connection_settings).check_login(attrs)
    end

    def connection_settings
      {
        ad_host:       settings.ad_host,
        ad_password:   settings.ad_password,
        ol1_host:      settings.ol1_host,
        ol1_password:  settings.ol1_password,
        ol2_host:      settings.ol2_host,
        ol2_password:  settings.ol2_password
      }
    end

    def response_handler
      res = yield
      {
        status: res[:status],
        data:   res[:data]
      }.to_json
    rescue NauLdap::LdapInteractionError, NauLdap::AccountNotFound, NauLdap::InvalidAttributeError => e
      {
        status: 'ERROR',
        error: 'Ошибка взаимодействия с LDAP',
        details: {
          error: "#{e.class}, message: #{e.message}"
        }
      }.to_json
    end
  end
end
