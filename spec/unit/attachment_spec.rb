require 'spec_helper'

describe Attachment do
  # associations
  it { should belong_to(:message) }

  # validations
  it { should validate_presence_of(:message) }
  it { should validate_presence_of(:file) }
end