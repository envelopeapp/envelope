require 'spec_helper'

describe Attachment do
  subject { build(:attachment) }

  # associations
  it { should be_embedded_in(:message) }

  # validations
  it { should validate_presence_of(:filename) }
end
