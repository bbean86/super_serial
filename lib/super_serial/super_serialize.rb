module SuperSerial #like, for srs
  module ClassMethods
    attr_accessor :column_name

    # Use this method if you need a more robust serialized column. The first argument is the column to store
    # the serialized data in. From the hash argument, it will define getters and setters for each symbol
    # or key from the with_defaults hash you pass to it. It handles adding each entry to attr_accessible, which
    # means you will be able to access values from your serialized column like any other ActiveRecord attr_accessible.
    # This is handy for forms, especially.
    #
    # HANDLING DEFAULTS
    #
    # This method will set default return values for any entries defined. If the default is a boolean value, it will
    # define a getter instance method ending in ?. Note that once a default is set, the type cannot be changed.
    #
    # USAGE EXAMPLES
    #
    # class AwesomeClass < ActiveRecord::Base
    #   super_serialize :super_column, entry_1: 'SOME DEFAULT VALUE', entry_2: nil, entry_3: true
    # end

    def super_serialize(_column_name, *entries)
      self.column_name = _column_name.to_s
      # raise Exception.new("#{ self.name } does not have a #{ column_name } column") unless self.column_names.include?(column_name)

      # please remove the line below and uncomment the exception above once the VenueSettings migration has been run
      return unless self.column_names.include?(column_name)

      serialize column_name.to_sym, OpenStruct
      attr_accessible(column_name)

      entries.each do |entry|
        handle_entry(entry)
      end
    end

    private

    def handle_entry(entry)
      entry.each_pair do |entry_name, default_value|
        define_getters_and_setters(entry_name)
        attr_accessible(entry_name)

        if !!default_value == default_value # is a boolean
          class_eval <<-RUBY, __FILE__, __LINE__ +1
                      def #{ entry_name }?
                        #{ entry_name }
                      end
          RUBY
        end
      end
      self.send(:before_validation, proc { set_entry_default(entry) }, {on: :create})
      self.send(:before_validation, proc { check_serialized_data_types(entry) })
    end

    def define_getters_and_setters(entry)
      class_eval <<-RUBY, __FILE__, __LINE__ +1
              def #{ entry }
      #{ column_name }.#{ entry }
              end

              def #{ entry }=(arg)
                #{ column_name }.#{ entry } = arg
              end
      RUBY
    end
  end

  private

  def set_entry_default(entry)
    entry.each_pair do |entry_name, default_value|
      set_entry_value(default_value, entry_name)
    end
  end

  def check_serialized_data_types(entry)
    entry.each_pair do |entry_name, default_value|
      if default_value.present?
        default_class_name = get_friendly_default_class(default_value)
        errors.add(:base, "#{ entry_name.to_s } can only be stored as a #{ default_class_name.downcase }") unless entry_type_valid?(default_class_name, entry_name)
      end
    end
    errors.empty?
  end

  def get_friendly_default_class(default_value)
    get_friendly_class_name(default_value.class.name)
  end

  def entry_type_valid?(default_class_name, entry_name)
    entry_class_name = get_friendly_class_name(send(entry_name).class.name)
    entry_class_name == default_class_name || entry_can_be_converted?(default_class_name, entry_name)
  end

  CONVERSIONS = {
      fixnum: :to_i,
      float: :to_f
  }

  def entry_can_be_converted?(default_class_name, entry_name)
    symbolized_class_name = default_class_name.downcase.to_sym
    converted_value       = cast_value_for_entry(entry_name, symbolized_class_name)
    try_conversion(converted_value, entry_name)
  end

  def cast_value_for_entry(entry_name, default_class_type)
    if default_class_type == :boolean
      cast_to_boolean(send(entry_name))
    else
      return unless CONVERSIONS.has_key?(default_class_type)
      send(entry_name).try(CONVERSIONS[default_class_type])
    end
  end

  TRUE_VALUES = [true, 1, '1', 'true', 'TRUE']

  def cast_to_boolean(entry_value)
    entry_value.in?(TRUE_VALUES)
  end

  def try_conversion(converted_value, entry_name)
    converted_value.nil? ? false : set_entry_value(converted_value, entry_name)
  end

  def set_entry_value(value, entry_name)
    send("#{entry_name}=", value)
    true
  end

  def get_friendly_class_name(class_name)
    class_name.in?(%w[TrueClass FalseClass]) ? 'Boolean' : class_name
  end
end