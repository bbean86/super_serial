module SuperSerial
  class Value
    def initialize(entry_name, default_value, klass_instance)
      @entry_name               = entry_name
      @default_value            = default_value
      @default_value_class_name = get_friendly_class_name(default_value.class.name)
      @current_value            = klass_instance.send(entry_name)
      @current_value_class_name = get_friendly_class_name(current_value.class.name)
      @klass_instance           = klass_instance
    end

    def cast_and_validate
      return true if default_value.nil?

      unless valid_or_castable?
        klass_instance.errors.add(:base, "#{ entry_name } can only be stored as a #{ default_value_class_name }")
      end

      klass_instance.errors.empty?
    end

    private

      attr_reader :entry_name,
                  :default_value,
                  :klass_instance,
                  :default_value_class_name,
                  :current_value,
                  :current_value_class_name

      def valid_or_castable?
        current_value_class_name == default_value_class_name || casted?
      end

      def get_friendly_class_name(class_name)
        class_name.in?(%w[TrueClass FalseClass]) ? :boolean : class_name.downcase.to_sym
      end

      def casted?
        cast_value.nil? ? false : klass_instance.set_super_serial_value(cast_value, entry_name)
      end

      TRUE_VALUES = [true, 1, '1', 'true', 'TRUE']
      CONVERSIONS = { fixnum: :to_i, float: :to_f }

      def cast_value
        if default_value_class_name == :boolean
          current_value.in?(TRUE_VALUES)
        elsif !!current_value.try(:match, /^[[:digit:]]/) || current_value == ''
          current_value.try(CONVERSIONS[default_value_class_name])
        elsif current_value.nil?
          current_value.send(CONVERSIONS[default_value_class_name])
        end
      end
  end
end