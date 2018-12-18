# ./config.ru
require 'sinatra'
require 'bundler'
require 'rubygems'

require File.dirname(__FILE__) + '/app'

configure :development do
  App.set :ad_host,      'host'
  App.set :ad_password,  'password'
  App.set :ad_bind_dn,   'dn for connection'
  App.set :ad_base,      'standard base for account'

  App.set :ol1_host,      'host'
  App.set :ol1_password,  'password'
  App.set :ol1_bind_dn,   'dn for connection'
  App.set :ol1_base,      'standard base for account'

  App.set :ol2_host,      'host'
  App.set :ol2_password,  'password'
  App.set :ol2_bind_dn,   'dn for connection'
  App.set :ol2_base,      'standard base for account'
end

configure :production do
  App.set :ad_host,      'prod host'
  App.set :ad_password,  'prod password'
  App.set :ad_bind_dn,   'prod dn for connection'
  App.set :ad_base,      'prod standard base for account'

  App.set :ol1_host,      'prod host'
  App.set :ol1_password,  'prod password'
  App.set :ol1_bind_dn,   'prod dn for connection'
  App.set :ol1_base,      'prod standard base for account'

  App.set :ol2_host,      'prod host'
  App.set :ol2_password,  'prod password'
  App.set :ol2_bind_dn,   'prod dn for connection'
  App.set :ol2_base,      'prod standard base for account'
end

Bundler.require

run App

