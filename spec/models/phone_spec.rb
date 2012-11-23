require 'spec_helper'

describe Phone do
  subject { build(:phone) }

  # assocations
  it { should be_embedded_in(:contact) }

  # validations
  it { should validate_presence_of(:label) }
  it { should validate_presence_of(:phone_number) }
end
