require 'spec_helper'

describe SuperSerial::ValueTypeValidator do
  before :each do
    @default_boolean = false
    @default_float   = 2.0
    @default_int     = 2
    @default_string  = 'Some string'
    ClassToSuperSerialize.super_serialize :foo_column, string_entry: @default_string, int_entry: @default_int, float_entry: @default_float, boolean_entry: @default_boolean, nil_entry: nil

    @instance = ClassToSuperSerialize.create
  end

  it 'does not allow a value of a different type to be stored' do
    @instance.int_entry = 'This is not an integer'
    SuperSerial::ValueTypeValidator.validate({ int_entry: @default_int }, @instance).should eql(false)
  end

  it 'allows boolean values to be changed' do
    @instance.boolean_entry = true
    SuperSerial::ValueTypeValidator.validate({ boolean_entry: @default_boolean }, @instance).should eql(true)
    @instance.boolean_entry.should eql(true)
  end

  it 'adds errors to the instance of the class using SuperSerial' do
    @instance.int_entry = 'This is not an integer'
    SuperSerial::ValueTypeValidator.validate({ int_entry: @default_int }, @instance)
    @instance.errors.full_messages.size.should eql(1)
  end

  it 'does not validate nil default values' do
    @instance.nil_entry = 'I can set this to anything'
    SuperSerial::ValueTypeValidator.validate({ nil_entry: nil }, @instance).should eql(true)
    @instance.nil_entry = :yes_you_can
    SuperSerial::ValueTypeValidator.validate({ nil_entry: nil }, @instance).should eql(true)
    @instance.nil_entry = true
    SuperSerial::ValueTypeValidator.validate({ nil_entry: nil }, @instance).should eql(true)
    @instance.nil_entry = 5
    SuperSerial::ValueTypeValidator.validate({ nil_entry: nil }, @instance).should eql(true)
  end
end