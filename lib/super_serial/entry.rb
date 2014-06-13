module SuperSerial
  class Entry
    attr_accessor :name, :value

    def initialize(name, value, klass, column_name)
      self.name        = name
      self.value       = value
      self.klass       = klass
      self.column_name = column_name

      generate
    end

    private
      attr_accessor :klass, :column_name

      def generate
        define_getter_and_setter
        klass.attr_accessible name
        define_boolean_accessor if !!value == value
        set_callbacks
      end

      def define_getter_and_setter
        klass.class_eval <<-RUBY, __FILE__, __LINE__ +1
          def #{ name }
            #{ column_name }.#{ name }
          end

          def #{ name }=(arg)
            #{ column_name }.#{ name } = arg
          end
        RUBY
      end

      def define_boolean_accessor
        klass.class_eval <<-RUBY, __FILE__, __LINE__ +1
          def #{ name }?
            #{ name }
          end
        RUBY
      end

      def set_callbacks
        klass.send(:after_initialize, set_default_value_lambda(name, value))
        klass.send(:before_validation, validate_value_lambda(name, value))
      end

      def validate_value_lambda(_name, _value)
        ->{ Value.new(_name, _value, self).cast_and_validate if entry_is_serialized?(_name) }
      end

      def set_default_value_lambda(_name, _value)
        ->{ set_super_serial_value(_value, _name) if entry_is_serialized?(_name) and new_record? }
      end
  end
end
