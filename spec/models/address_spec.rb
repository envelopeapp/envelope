require 'spec_helper'

describe Address do
  subject { build(:address) }

  # associations
  it { should be_embedded_in(:contact) }
end
