require 'active_support'
require 'ostruct'
require "super_serial/version"
require 'super_serial/super_serialize'
require 'super_serial/value_type_validator'
require 'super_serial/value_converter'
require 'super_serial/entry'

module SuperSerial
  extend ActiveSupport::Concern

  included do
    raise Exception.new('SuperSerial requires a class that inherits ActiveRecord::Base') unless ancestors.include?(ActiveRecord::Base)
  end
end
