module SuperSerial
  class Entry
    attr_accessor :name, :value

    def initialize(name, value, klass, column_name)
      self.name        = name
      self.value       = value
      self.klass       = klass
      self.column_name = column_name

      handle_entry
    end

    def handle_entry
      define_getter_and_setter
      klass.attr_accessible name
      define_boolean_accessor if !!value == value
      set_callbacks
    end

    private
      attr_accessor :klass, :column_name

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
        _self  = self
        klass.send(:before_validation, proc { set_entry_value(_value, _name) if entry_is_serialized?(_name) }, { on: :create })
        klass.send(:before_validation, proc { ValueTypeValidator.validate(_self, self) if entry_is_serialized?(_name) })
      end
  end
end
