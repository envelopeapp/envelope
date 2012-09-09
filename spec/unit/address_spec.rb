require 'spec_helper'

describe Address do
  # associations
  it { should be_embedded_in(:contact) }
end
