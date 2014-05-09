require 'active_support'
require "super_serial/version"
require 'super_serial/super_serialize'
require 'super_serial/value_validator'
require 'super_serial/value_converter'

module SuperSerial
  extend ActiveSupport::Concern

  included do
    raise Exception.new('SuperSerial requires a class that inherits ActiveRecord::Base') unless ancestors.include?(ActiveRecord::Base)
  end
end
