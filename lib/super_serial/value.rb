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

      unless valid_or_casted?
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

      def valid_or_casted?
        current_value_class_name == default_value_class_name || casted?
      end

      def get_friendly_class_name(class_name)
        class_name.in?(%w[TrueClass FalseClass]) ? :boolean : class_name.downcase.to_sym
      end

      def casted?
        casted_value = get_casted_value
        casted_value.nil? ? false : klass_instance.set_super_serial_value(casted_value, entry_name)
      end

      TRUE_VALUES = [true, 1, '1', 'true', 'TRUE']
      CONVERSIONS = { fixnum: :to_i, float: :to_f }

      def get_casted_value
        if default_value_class_name == :boolean
          current_value.in?(TRUE_VALUES)
        elsif value_numeric_or_empty?
          current_value.try(CONVERSIONS[default_value_class_name])
        elsif current_value.nil? and default_value_class_name.in?([:fixnum, :float])
          current_value.send(CONVERSIONS[default_value_class_name])
        elsif default_value_class_name == :string
          current_value || ''
        end
      end

      def value_numeric_or_empty?
        !!current_value.try(:match, /^[[:digit:]]/) || current_value == ''
      end
  end
end