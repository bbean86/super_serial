module SuperSerial #like, for srs
  module ClassMethods
    attr_accessor :super_serial_column_name, :serialized_entry_names

    # Use this method if you need a more robust serialized column. The first argument denotes the column to store
    # the serialized data in. From the remaining hash argument, it will define getters and setters using
    # the given key-value pairs to assign default values to named entries. Each entry is added to attr_accessible.
    #
    # +defaults+
    #
    # This method will set default return values for any entries defined. If the default is a boolean value, it will
    # define a getter instance method ending in ?. It infers the default value's type and validates values against that type.
    # It has built-in ActiveRecord-style automatic type conversions for convertible values. Note that once a default is set,
    # any change to its type will need to be accompanied by a migration to change any stored data to the correct type.
    #
    #
    # +usage+
    #
    # class AwesomeClass < ActiveRecord::Base
    #   include SuperSerial
    #   super_serialize :super_column, entry_1: 'SOME DEFAULT VALUE', entry_2: nil, entry_3: true
    # end

    def super_serialize(_column_name, entries)
      self.super_serial_column_name = _column_name.to_s
      self.serialized_entry_names   = entries.keys

      serialize super_serial_column_name.to_sym, DataStruct

      entries.each_pair do |entry_name, default_value|
        SuperSerial::Entry.new(entry_name, default_value, self, super_serial_column_name)
      end
    end
  end

  def set_super_serial_value(value, entry_name)
    unless entry_is_serialized?(entry_name)
      raise "#{ entry_name } must be an entry serialized in the #{ self.class.super_serial_column_name } column"
    end

    send("#{ entry_name }=", value)
    send(entry_name) == value
  end

  private

  def entry_is_serialized?(entry_name)
    entry_name.to_sym.in?(self.class.serialized_entry_names.to_a)
  end

  def entry_needs_default?(_name)
    send(self.class.super_serial_column_name).send(_name).nil?
  end
end