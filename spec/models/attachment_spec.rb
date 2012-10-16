require 'spec_helper'

describe Attachment do
  # associations
  it { should be_embedded_in(:message) }

  # validations
  it { should validate_presence_of(:filename) }
  it { should validate_presence_of(:size) }
end
