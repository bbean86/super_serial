require 'spec_helper'

describe SuperSerial::Entry do
  before :all do
    Temping.create :entry_test do
      include SuperSerial

      with_columns do |t|
        t.text :foo_column
      end
    end
  end
  
  before :each do
    @entry = SuperSerial::Entry.new('name', 'Ben', EntryTest, :foo_column)
  end

  it 'holds a reference to the abstract class' do
    @entry.send(:klass).should eql(EntryTest)
  end

  context 'on the abstract class' do
    before :each do
      @instance = EntryTest.new
    end

    it 'defines a getter and setter' do
      @instance.respond_to?(:name).should eql(true)
      @instance.respond_to?(:name=).should eql(true)
    end

    it 'adds the entry name to the attr_accessible' do
      EntryTest.accessible_attributes.include?('name').should eql(true)
    end

    context 'with a boolean default value' do
      it 'defines an accessor method ending in ?' do
        SuperSerial::Entry.new('enabled', true, EntryTest, :foo_column)
        @instance.respond_to?(:enabled?).should eql(true)
      end
    end
  end
end