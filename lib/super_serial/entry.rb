module SuperSerial
  class Entry
    attr_accessor :name, :value

    def initialize(name, value, klass, column_name)
      self.name        = name
      self.value       = value
      self.klass       = klass
      self.column_name = column_name

      handle
    end

    private
      attr_accessor :klass, :column_name

      def handle
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
        #store in temps for correct context at proc runtime
        _name  = name
        _value = value
        klass.send(:before_validation, proc { set_super_serial_value(_value, _name) if entry_is_serialized?(_name) }, { on: :create })
        klass.send(:before_validation, proc { Value.new(_name, _value, self).cast_and_validate if entry_is_serialized?(_name) })
      end
  end
end
