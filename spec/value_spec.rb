require 'spec_helper'

describe SuperSerial::Value do
  before :all do
    Temping.create :second_class_to_super_serialize do
      include SuperSerial

      with_columns do |t|
        t.text :foo_column
      end
    end
  end

  before :each do
    @default_boolean = false
    @default_float   = 2.0
    @default_int     = 2
    @default_string  = 'Some string'
    SecondClassToSuperSerialize.super_serialize :foo_column, string_entry: @default_string, int_entry: @default_int, float_entry: @default_float, boolean_entry: @default_boolean, nil_entry: nil

    @instance = SecondClassToSuperSerialize.create
  end

  it 'does not allow a value of a different type to be stored' do
    @instance.int_entry = 'This is not an integer'
    SuperSerial::Value.validate('int_entry', @default_int, @instance).should eql(false)
  end

  it 'allows boolean values to be changed' do
    @instance.boolean_entry = true
    SuperSerial::Value.validate('boolean_entry', @default_boolean, @instance).should eql(true)
    @instance.boolean_entry.should eql(true)
  end

  it 'adds errors to the instance of the class using SuperSerial' do
    @instance.int_entry = 'This is not an integer'
    SuperSerial::Value.validate('int_entry', @default_int, @instance)
    @instance.errors.full_messages.size.should eql(1)
  end

  it 'does not validate nil default values' do
    @instance.nil_entry = 'I can set this to anything'
    SuperSerial::Value.validate('nil_entry', nil, @instance).should eql(true)
    @instance.nil_entry = :yes_you_can
    SuperSerial::Value.validate('nil_entry', nil, @instance).should eql(true)
    @instance.nil_entry = true
    SuperSerial::Value.validate('nil_entry', nil, @instance).should eql(true)
    @instance.nil_entry = 5
    SuperSerial::Value.validate('nil_entry', nil, @instance).should eql(true)
  end

  context '#convertible?' do
    before :each do
      @conversion_method = ->(value_arg) { true }
    end

    it 'returns true if conversion is successful' do
      SuperSerial::Value.send(:convertible?, 'true', :boolean, @conversion_method).should eql(true)
    end

    it 'returns false if conversion fails' do
      SuperSerial::Value.send(:convertible?, 'true2', :float, @conversion_method).should eql(false)
    end

    it 'converts a given value to the correct type if possible' do
      @conversion_method.should_receive(:call).with(2.0).and_return(true)
      SuperSerial::Value.send(:convertible?, '2.0', :float, @conversion_method).should eql(true)
    end

    context 'fixnum conversions' do
      it 'converts an empty string into 0' do
        @conversion_method.should_receive(:call).with(0).and_return(true)
        SuperSerial::Value.send(:convertible?, '', :fixnum, @conversion_method).should eql(true)
      end

      it 'converts nil to 0' do
        @conversion_method.should_receive(:call).with(0).and_return(true)
        SuperSerial::Value.send(:convertible?, nil, :fixnum, @conversion_method).should eql(true)
      end
    end

    context 'float conversions' do
      it 'converts an empty string into 0.0' do
        @conversion_method.should_receive(:call).with(0.0).and_return(true)
        SuperSerial::Value.send(:convertible?, '', :float, @conversion_method).should eql(true)
      end

      it 'converts nil to 0.0' do
        @conversion_method.should_receive(:call).with(0.0).and_return(true)
        SuperSerial::Value.send(:convertible?, nil, :float, @conversion_method).should eql(true)
      end
    end

    context 'boolean conversions' do
      it 'converts 1 to true' do
        @conversion_method.should_receive(:call).with(true).and_return(true)
        SuperSerial::Value.send(:convertible?, 1, :boolean, @conversion_method).should eql(true)
      end

      it "converts '1' to true" do
        @conversion_method.should_receive(:call).with(true).and_return(true)
        SuperSerial::Value.send(:convertible?, '1', :boolean, @conversion_method).should eql(true)
      end

      it "converts 'true' to true" do
        @conversion_method.should_receive(:call).with(true).and_return(true)
        SuperSerial::Value.send(:convertible?, 'true', :boolean, @conversion_method).should eql(true)
      end

      it 'converts anything else to false' do
        @conversion_method.should_receive(:call).exactly(5).times.with(false).and_return(true)
        SuperSerial::Value.send(:convertible?, nil, :boolean, @conversion_method).should eql(true)
        SuperSerial::Value.send(:convertible?, 'OMGHAX', :boolean, @conversion_method).should eql(true)
        SuperSerial::Value.send(:convertible?, 1000, :boolean, @conversion_method).should eql(true)
        SuperSerial::Value.send(:convertible?, 2.0, :boolean, @conversion_method).should eql(true)
        SuperSerial::Value.send(:convertible?, '', :boolean, @conversion_method).should eql(true)
      end
    end
  end
end