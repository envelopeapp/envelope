require 'spec_helper'

FactoryGirl.factories.map(&:name).each do |factory_name|
  describe "The '#{factory_name}' factory" do
    it 'is valid' do
      instance = build(factory_name)
      instance.valid?.should be_true
      instance.errors.full_messages.to_sentence
    end
  end
end
