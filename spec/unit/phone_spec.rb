require 'spec_helper'

describe Phone do
  # assocations
  it { should belong_to(:contact) }

  # validations
  it { should validate_presence_of(:contact) }
  it { should validate_presence_of(:label) }
  it { should validate_presence_of(:phone_number) }
end