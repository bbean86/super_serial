require 'bundler/setup'
Bundler.setup

require 'super_serial'
require 'temping'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')