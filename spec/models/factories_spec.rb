require 'spec_helper'

FactoryGirl.factories.each do |factory|
  describe "The '#{factory.name}' factory" do
    it 'is valid' do
      instance = build(factory.name)
      instance.valid?.should be_true
      instance.errors.full_messages.to_sentence
    end
  end
end
