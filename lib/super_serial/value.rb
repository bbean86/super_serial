module SuperSerial
  class Value
    class << self
      def validate(entry_name, entry_default_value, instance)
        return true if entry_default_value.nil?

        default_value_class = get_friendly_class_name(entry_default_value.class.name)
        value_setter        = ->(converted_value) { instance.set_entry_value(converted_value, entry_name) }

        unless value_type_valid?(default_value_class, instance.send(entry_name), value_setter)
          instance.errors.add(:base, "#{ entry_name.to_s } can only be stored as a #{ default_value_class.downcase }")
        end

        instance.errors.empty?
      end

      private
        def value_type_valid?(default_value_class, value, value_setter)
          get_friendly_class_name(value.class.name) == default_value_class || convertible?(value, default_value_class.downcase.to_sym, value_setter)
        end

        def convertible?(value, conversion_class, value_setter)
          converted_value = cast_value(value, conversion_class)
          try_conversion(converted_value, value_setter)
        end

        private
        CONVERSIONS = {
            fixnum: :to_i,
            float: :to_f
        }

        def cast_value(value, conversion_class)
          if conversion_class == :boolean
            cast_to_boolean(value)
          elsif !!value.try(:match, /^[[:digit:]]/) || value == ''
            value.try(CONVERSIONS[conversion_class])
          elsif value.nil?
            value.send(CONVERSIONS[conversion_class])
          end
        end

        TRUE_VALUES = [true, 1, '1', 'true', 'TRUE']

        def cast_to_boolean(entry_value)
          entry_value.in?(TRUE_VALUES)
        end

        def try_conversion(converted_value, value_setter)
          converted_value.nil? ? false : value_setter.call(converted_value)
        end

        def get_friendly_class_name(class_name)
          class_name.in?(%w[TrueClass FalseClass]) ? 'Boolean' : class_name
        end
    end
  end
end