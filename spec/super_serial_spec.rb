require 'spec_helper'

describe SuperSerial do
  it 'cannot be included in non AR classes' do
    expect {
      class NonActiveRecord
        include SuperSerial
      end
    }.to raise_exception(Exception)
  end

  it "raises an exception if the given column name does not exist in the class's column_names list" do
    expect {
      ClassToSuperSerialize.super_serialize :does_not_exist, foo: 'bar'
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

      it "adds the given attributes to the class's attr_accessible array" do
        [:name, :male, :height, :bar_attribute].each do |entry|
          ClassToSuperSerialize.accessible_attributes.include?(entry).should eql(true)
        end
      end

      context 'an instance of the class calling .super_serialize' do
        before :each do
          @instance = ClassToSuperSerialize.new
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