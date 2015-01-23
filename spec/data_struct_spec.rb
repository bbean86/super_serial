require 'spec_helper'

describe DataStruct do
  let(:data_struct) { DataStruct.new(name: 'my_struct') }

  describe '#to_json' do
    subject { JSON.parse(data_struct.to_json) }
    it { should have_key('name') }
    it { should have_value('my_struct') }
  end
end