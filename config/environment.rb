ENV['SINATRA_ENV'] ||= "development"
ENV['RACK_ENV'] ||= "development"

require 'bundler'
require 'rubygems'

Bundler.require(:default, ENV['SINATRA_ENV'])

require './app'


# development:
#   ad_host: tempxdc1.nau.res
#   ad_password: Zaqwsx147852
#
#   ol1_host: ldap-test.naumen.ru
#   ol1_password: YRp4NS6YfYAWNrlzKV
#
#   ol2_host: ldapadmin-test.naumen.ru
#   ol2_password: YRp4NS6YfYAWNrlzKV
#
# production:
#   ad_host:
#   ad_password:
#
#   ol1_host:
#   ol1_password:
#
#   ol2_host:
#   ol2_password:

