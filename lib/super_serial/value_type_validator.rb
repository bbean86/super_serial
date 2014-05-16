module SuperSerial
  class ValueTypeValidator
    class << self
      def validate(entry_name, entry_default_value, instance)
        return true if entry_default_value.nil?

        default_value_class = get_friendly_class_name(entry_default_value.class.name)
        value_setter        = lambda{ |converted_value| instance.set_entry_value(converted_value, entry_name) }

        unless value_type_valid?(default_value_class, instance.send(entry_name), value_setter)
          instance.errors.add(:base, "#{ entry_name.to_s } can only be stored as a #{ default_value_class.downcase }")
        end

        instance.errors.empty?
      end

      private
        def value_type_valid?(default_value_class, value, value_setter)
          get_friendly_class_name(value.class.name) == default_value_class || ValueConverter.convertible?(value, default_value_class.downcase.to_sym, value_setter)
        end

        def get_friendly_class_name(class_name)
          class_name.in?(%w[TrueClass FalseClass]) ? 'Boolean' : class_name
        end
    end
  end
end