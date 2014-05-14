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
      # raise Exception.new("#{ self.name } does not have a #{ column_name } column") unless self.column_names.include?(column_name)

      # please remove the line below and uncomment the exception above once the VenueSettings migration has been run
      return unless self.column_names.include?(super_serial_column_name)

      serialize super_serial_column_name.to_sym, OpenStruct

      entries.each_pair do |entry_name, default_value|
        handle_entry({"#{entry_name}" => default_value})
      end
    end

    private
      def handle_entry(entry)
        entry.each_pair do |entry_name, default_value|
          define_getter_and_setter(entry_name)
          attr_accessible(entry_name)
          define_boolean_accessor(entry_name) if !!default_value == default_value # is a boolean
        end
        set_callbacks(entry)
      end

      def define_boolean_accessor(entry_name)
        class_eval <<-RUBY, __FILE__, __LINE__ +1
              def #{ entry_name }?
                #{ entry_name }
              end
        RUBY
      end

      def set_callbacks(entry)
        self.send(:before_validation, proc { set_entry_default(entry) }, { on: :create })
        self.send(:before_validation, proc { check_serialized_data_type(entry) })
      end

      def define_getter_and_setter(entry)
        class_eval <<-RUBY, __FILE__, __LINE__ +1
                def #{ entry }
                  #{ super_serial_column_name }.#{ entry }
                end

                def #{ entry }=(arg)
                  #{ super_serial_column_name }.#{ entry } = arg
                end
        RUBY
      end
  end

  def set_entry_value(value, entry_name)
    raise Exception.new("#{ entry_name } must be an entry serialized in the #{ self.class.super_serial_column_name } column") unless entry_is_serialized?(entry_name)

    send("#{ entry_name }=", value)
    send(entry_name) == value
  end

  private
    def set_entry_default(entry)
      entry.each_pair do |entry_name, default_value|
        set_entry_value(default_value, entry_name) if entry_is_serialized?(entry_name)
      end
    end

    def check_serialized_data_type(entry)
      ValueTypeValidator.validate(entry, self) if entry_is_serialized?(entry.keys.first)
    end

    def entry_is_serialized?(entry_name)
      entry_name.to_sym.in?(self.class.serialized_entry_names)
    end
end