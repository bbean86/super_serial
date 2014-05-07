require 'spec_helper'

describe SuperSerial do
  before :all do
    @klass = Temping.create :class_to_super_serialize do
      include SuperSerial

      with_columns do |t|
        t.text :foo_column
      end
    end
  end

  it 'cannot be included in non AR classes' do
    expect {
      class NonActiveRecord
        include SuperSerial
      end
    }.to raise_exception(Exception)
  end

  context '.super_serialize' do
    it 'serializes the data given in the column given by the first argument' do
      @klass.should_receive(:serialize).with(:foo_column, OpenStruct)
      @klass.super_serialize :foo_column, name: 'Billy'
    end

    context 'with appropriate args' do
      before :each do
        @klass.super_serialize :foo_column, name: 'Billy', male: true, height: 70, bar_attribute: nil
      end

      it "adds the given attributes to the class's attr_accessible array" do
        [:name, :male, :height, :bar_attribute].each do |entry|
          @klass.accessible_attributes.include?(entry).should eql(true)
        end
      end

      context 'an instance of the class calling .super_serialize' do
        before :each do
          @instance = @klass.new
        end

        it 'responds to instance methods ending in ? for each entry given with a boolean default' do
          @instance.respond_to?(:male?).should eql(true)
        end

        it 'responds to instance methods which access the serialized values' do
          [:name, :male, :height, :bar_attribute].each do |accessor_method|
            @instance.respond_to?(accessor_method).should eql(true)
          end
        end

        it 'responds to instance methods which set the serialized values' do
          [:name=, :male=, :height=, :bar_attribute=].each do |setter_method|
            @instance.respond_to?(setter_method).should eql(true)
          end
        end

        context 'that is a new record' do
          before :each do
            @instance.save unless @instance.persisted?
          end

          it 'sets the default values for the entries given' do
            { name: 'Billy', male: true, height: 70 }.each_pair do |entry_name, default_value|
              @instance.send(entry_name).should eql(default_value)
            end
          end
        end

        context 'column validations' do
          before :each do
            @instance = @klass.create
          end

          it 'does not allow a value of a different type to be stored' do
            @instance.name = 3
            @instance.save.should eql(false)
            @instance.errors.full_messages.first.should eql('name can only be stored as a string')
          end

          it 'allows boolean values to be changed' do
            @instance.male = false
            @instance.save.should eql(true)
            @instance.errors.empty?.should eql(true)
          end

          it 'does not validate nil default values' do
            @instance.bar_attribute = false
            @instance.save.should eql(true)
            @instance.errors.empty?.should eql(true)
            @instance.bar_attribute = 'foo'
            @instance.save.should eql(true)
            @instance.errors.empty?.should eql(true)
            @instance.bar_attribute = 3
            @instance.save.should eql(true)
            @instance.errors.empty?.should eql(true)
          end
          
          context 'automatic type conversions' do
            it 'convert a given value to the correct type if possible' do
              @instance.height = '65'
              @instance.save.should eql(true)
              @instance.height.should eql(65)
            end

            context 'boolean conversions' do
              it 'convert 1 to true' do
                @instance.male = 1
                @instance.save.should eql(true)
                @instance.male.should eql(true)
              end

              it "convert '1' to true" do
                @instance.male = '1'
                @instance.save.should eql(true)
                @instance.male.should eql(true)
              end

              it "convert 'true' to true" do
                @instance.male = 'true'
                @instance.save.should eql(true)
                @instance.male.should eql(true)
              end

              it 'convert anything else to false' do
                @instance.male = 'OMGHAX'
                @instance.save.should eql(true)
                @instance.male.should eql(false)
                @instance = @klass.create
                @instance.male = 'false'
                @instance.save.should eql(true)
                @instance.male.should eql(false)
              end
            end
          end
        end
      end
    end
  end
end