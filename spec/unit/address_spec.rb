require 'spec_helper'

describe Address do
  # associations
  it { should belong_to(:contact) }

  # validations
  it { should validate_presence_of(:contact) }
end