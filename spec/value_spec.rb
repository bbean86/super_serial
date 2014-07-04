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
    SuperSerial::Value.new('int_entry', @default_int, @instance).cast_and_validate.should eql(false)
    @instance.errors.full_messages.first.should eql('int_entry can only be stored as a fixnum')
  end

  it 'allows boolean values to be changed' do
    @instance.boolean_entry = true
    SuperSerial::Value.new('boolean_entry', @default_boolean, @instance).cast_and_validate.should eql(true)
    @instance.boolean_entry.should eql(true)
  end

  it 'adds errors to the instance of the class that is using SuperSerial' do
    @instance.int_entry = 'This is not an integer'
    SuperSerial::Value.new('int_entry', @default_int, @instance).cast_and_validate
    @instance.errors.full_messages.size.should eql(1)
  end

  it 'can cast nil to an empty string' do
    @instance.string_entry = nil
    SuperSerial::Value.new('string_entry', @default_string, @instance).cast_and_validate.should eql(true)
  end

  it 'does not validate nil default values' do
    @instance.nil_entry = 'I can set this to anything'
    SuperSerial::Value.new('nil_entry', nil, @instance).cast_and_validate.should eql(true)
    @instance.nil_entry = :yes_you_can
    SuperSerial::Value.new('nil_entry', nil, @instance).cast_and_validate.should eql(true)
    @instance.nil_entry = true
    SuperSerial::Value.new('nil_entry', nil, @instance).cast_and_validate.should eql(true)
    @instance.nil_entry = 5
    SuperSerial::Value.new('nil_entry', nil, @instance).cast_and_validate.should eql(true)
  end

  context 'fixnum conversions' do
    it 'converts an empty string into 0' do
      @instance.int_entry = ''
      SuperSerial::Value.new('int_entry', 1, @instance).cast_and_validate.should eql(true)
      @instance.int_entry.should eql(0)
    end

    it 'converts nil to 0' do
      @instance.int_entry = nil
      SuperSerial::Value.new('int_entry', 1, @instance).cast_and_validate.should eql(true)
      @instance.int_entry.should eql(0)
    end
  end

  context 'float conversions' do
    it 'converts an empty string into 0.0' do
      @instance.float_entry = ''
      SuperSerial::Value.new('float_entry', 1.0, @instance).cast_and_validate.should eql(true)
      @instance.float_entry.should eql(0.0)
    end

    it 'converts nil to 0.0' do
      @instance.float_entry = nil
      SuperSerial::Value.new('float_entry', 1.0, @instance).cast_and_validate.should eql(true)
      @instance.float_entry.should eql(0.0)
    end
  end

  context 'boolean conversions' do
    it 'converts 1 to true' do
      @instance.boolean_entry = 1
      SuperSerial::Value.new('boolean_entry', false, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(true)
    end

    it "converts '1' to true" do
      @instance.boolean_entry = '1'
      SuperSerial::Value.new('boolean_entry', false, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(true)
    end

    it "converts 'true' to true" do
      @instance.boolean_entry = 'true'
      SuperSerial::Value.new('boolean_entry', false, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(true)
    end

    it 'converts anything else to false' do
      @instance.boolean_entry = nil
      SuperSerial::Value.new('boolean_entry', true, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(false)

      @instance.boolean_entry = 'OMGHAX'
      SuperSerial::Value.new('boolean_entry', true, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(false)

      @instance.boolean_entry = 1000
      SuperSerial::Value.new('boolean_entry', true, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(false)

      @instance.boolean_entry = 2.0
      SuperSerial::Value.new('boolean_entry', true, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(false)

      @instance.boolean_entry = ''
      SuperSerial::Value.new('boolean_entry', true, @instance).cast_and_validate.should eql(true)
      @instance.boolean_entry.should eql(false)
    end
  end
end