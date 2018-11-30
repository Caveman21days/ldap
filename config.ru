# ./config.ru
require 'sinatra'
require 'bundler'
require 'rubygems'

require File.dirname(__FILE__) + '/app'

configure :development do
  App.set :ad_host,     'tempxdc1.nau.res'
  App.set :ad_password, 'Zaqwsx147852'

  App.set :ol1_host,     'ldap-test.naumen.ru'
  App.set :ol1_password, 'YRp4NS6YfYAWNrlzKV'

  App.set :ol2_host,     'ldapadmin-test.naumen.ru'
  App.set :ol2_password, 'YRp4NS6YfYAWNrlzKV'
end

configure :production do
  App.set :ad_host,     ''
  App.set :ad_password, ''

  App.set :ol1_host,     ''
  App.set :ol1_password, ''

  App.set :ol2_host,     ''
  App.set :ol2_password, ''
end

Bundler.require

run App

