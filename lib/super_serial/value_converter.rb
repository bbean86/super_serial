module SuperSerial
  class ValueConverter
    class << self
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
    end
  end
end