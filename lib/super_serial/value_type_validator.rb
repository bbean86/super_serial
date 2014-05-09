module SuperSerial
  class ValueTypeValidator
    class << self
      def validate(entry, instance)
        entry_name    = entry.keys.first
        default_value = entry.values.first

        return true if default_value.nil?

        default_value_class = get_friendly_class_name(default_value.class.name)
        entry_value         = instance.send(entry_name)
        conversion_method   = lambda{ |converted_value| instance.set_entry_value(converted_value, entry_name) }

        unless value_type_valid?(default_value_class, entry_value, conversion_method)
          instance.errors.add(:base, "#{ entry_name.to_s } can only be stored as a #{ default_value_class.downcase }")
        end

        instance.errors.empty?
      end

      private
        def value_type_valid?(default_value_class, value, conversion_method)
          get_friendly_class_name(value.class.name) == default_value_class || ValueConverter.convertible?(value, default_value_class.downcase.to_sym, conversion_method)
        end

        def get_friendly_class_name(class_name)
          class_name.in?(%w[TrueClass FalseClass]) ? 'Boolean' : class_name
        end
    end
  end
end