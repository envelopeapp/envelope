require 'spec_helper'

describe Server do
  subject { build(:server) }
  # associations
  it { should embed_one(:authentication) }

  # validations
  it { should validate_presence_of(:address) }
  it { should validate_presence_of(:port) }
end
