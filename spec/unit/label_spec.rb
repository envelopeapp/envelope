require 'spec_helper'

describe Label do
  before(:all) do
    @label = build(:label)
  end

  # associations
  it { should belong_to(:user) }
  it { should have_and_belong_to_many(:messages) }

  # validations
  it { should validate_presence_of(:user) }
  it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
  it { should validate_presence_of(:name) }
end
