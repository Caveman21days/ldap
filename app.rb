require_relative './lib/nau_ldap'
require 'sinatra'
require 'json'

class App < Sinatra::Base

  post '/write' do
    write params[:attributes]
  end

  post '/update' do
    update params[:attributes]
  end

  post'/change_password' do
    response = JSON.parse(request.body.read)
    hr_id = response['hrID']
    pwd   = response['password']

    body change_password(hr_id, pwd).to_s
  end

  post '/deactivate_account' do
    deactivate_account params[:hr_id]
  end

  post '/check_login' do
    response = check_login(JSON.parse(request.body.read)['login'])
    res      = response.include?(true) ? 'Занят!' : 'Свободен!'
    body res
  end

  helpers do
    def write(attrs)
      NauLdap::RequestHandler.new(connection_settings).write(attrs)
    end

    def update(attrs)
      NauLdap::RequestHandler.new(connection_settings).update(attrs)
    end

    def change_password(hr_id, password)
      NauLdap::RequestHandler.new(connection_settings).change_password(hr_id, password)
    end

    def deactivate_account(hr_id)
      NauLdap::RequestHandler.new(connection_settings).deactivate_account(hr_id)
    end

    def check_login(login)
      NauLdap::RequestHandler.new(connection_settings).check_login(login)
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
  end
end
