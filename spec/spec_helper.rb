require 'bundler/setup'
Bundler.setup

require 'super_serial'
require 'temping'
require 'active_record'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

RSpec.configure do |config|
  Temping.create :class_to_super_serialize do
    include SuperSerial

    with_columns do |t|
      t.text :foo_column
    end
  end
end
