require 'spec_helper'

describe Email do
  # assocations
  it { should belong_to(:contact) }

  # validations
  it { should validate_presence_of(:contact) }
  it { should validate_presence_of(:label) }
  it { should validate_presence_of(:email_address) }
end