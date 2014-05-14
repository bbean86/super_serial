require 'spec_helper'

describe SuperSerial::ValueConverter do
  before :each do
    @conversion_method = lambda{ |value_arg| true }
  end

  it 'returns true if conversion is successful' do
    SuperSerial::ValueConverter.convertible?('true', :boolean, @conversion_method).should eql(true)
  end

  it 'returns false if conversion fails' do
    SuperSerial::ValueConverter.convertible?('true2', :float, @conversion_method).should eql(false)
  end

  it 'converts a given value to the correct type if possible' do
    @conversion_method.should_receive(:call).with(2.0).and_return(true)
    SuperSerial::ValueConverter.convertible?('2.0', :float, @conversion_method).should eql(true)
  end

  context 'fixnum conversions' do
    it 'converts an empty string into 0' do
      @conversion_method.should_receive(:call).with(0).and_return(true)
      SuperSerial::ValueConverter.convertible?('', :fixnum, @conversion_method).should eql(true)
    end
  end

  context 'float conversions' do
    it 'converts an empty string into 0.0' do
      @conversion_method.should_receive(:call).with(0.0).and_return(true)
      SuperSerial::ValueConverter.convertible?('', :float, @conversion_method).should eql(true)
    end
  end

  context 'boolean conversions' do
    it 'converts 1 to true' do
      @conversion_method.should_receive(:call).with(true).and_return(true)
      SuperSerial::ValueConverter.convertible?(1, :boolean, @conversion_method).should eql(true)
    end

    it "converts '1' to true" do
      @conversion_method.should_receive(:call).with(true).and_return(true)
      SuperSerial::ValueConverter.convertible?('1', :boolean, @conversion_method).should eql(true)
    end

    it "converts 'true' to true" do
      @conversion_method.should_receive(:call).with(true).and_return(true)
      SuperSerial::ValueConverter.convertible?('true', :boolean, @conversion_method).should eql(true)
    end

    it 'converts anything else to false' do
      @conversion_method.should_receive(:call).exactly(4).times.with(false).and_return(true)
      SuperSerial::ValueConverter.convertible?('OMGHAX', :boolean, @conversion_method).should eql(true)
      SuperSerial::ValueConverter.convertible?(1000, :boolean, @conversion_method).should eql(true)
      SuperSerial::ValueConverter.convertible?(2.0, :boolean, @conversion_method).should eql(true)
      SuperSerial::ValueConverter.convertible?('', :boolean, @conversion_method).should eql(true)
    end
  end
end