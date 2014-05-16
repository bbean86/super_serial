require 'spec_helper'

describe SuperSerial do
  it 'cannot be included in non AR classes' do
    expect {
      class NonActiveRecord
        include SuperSerial
      end
    }.to raise_exception(Exception)
  end

  it 'handles updates to the invocation of .super_serialize' do
    ClassToSuperSerialize.super_serialize :foo_column, foo_attribute: 'DEFAULT'
    expect { ClassToSuperSerialize.create }.not_to raise_exception(Exception)
    ClassToSuperSerialize.super_serialize :foo_column, bar_attribute: true
    expect { ClassToSuperSerialize.create }.not_to raise_exception(Exception)
  end

  context '.super_serialize' do
    it 'serializes the data given in the column given by the first argument' do
      ClassToSuperSerialize.should_receive(:serialize).with(:foo_column, OpenStruct)
      ClassToSuperSerialize.super_serialize :foo_column, name: 'Billy'
    end

    context 'with appropriate args' do
      before :each do
        ClassToSuperSerialize.super_serialize :foo_column, name: 'Billy', male: true, height: 70, bar_attribute: nil
      end
      context 'an instance of the class calling .super_serialize' do
        before :each do
          @instance = ClassToSuperSerialize.new
        end
        context 'that is a new record' do
          before :each do
            @instance.save!
          end
          it 'sets the default values for the entries given' do
            { name: 'Billy', male: true, height: 70 }.each_pair do |entry_name, default_value|
              @instance.send(entry_name).should eql(default_value)
            end
          end
        end
      end
    end
  end

  context '#set_entry_value' do
    before :each do
      ClassToSuperSerialize.super_serialize :foo_column, name: 'Billy', male: true, height: 70, bar_attribute: nil
      @instance = ClassToSuperSerialize.create
    end

    it 'returns a boolean' do
      @instance.set_entry_value('Nick Fury', :name).should eql(true)
    end

    it 'sets the entry to the value given' do
      @instance.set_entry_value('Bruce Banner', :name)
      @instance.name.should eql('Bruce Banner')
    end
  end
end