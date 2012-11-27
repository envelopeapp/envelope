require 'spec_helper'

describe User do
  subject { build(:user) }
  let(:user) { subject }

  # assocations
  it { should have_many(:accounts) }

  it { should have_many(:labels) }
  it { should have_many(:contacts) }

  # validations
  it { should validate_uniqueness_of(:username) }
  it { should validate_uniqueness_of(:email_address) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email_address) }
  it { should validate_confirmation_of(:password) }

  # methods
  its(:name) { should == 'Bill Jones' }

  describe '#name=' do
    it 'sets the correct first_nane' do
      user.name = 'Sample User'

      user.first_name.should == 'Sample'
      user.last_name.should == 'User'
    end
  end

  describe '#confirm' do
    it 'does not raise an exception when confirmation_token is nil' do
      lambda { user.confirm(nil) }.should_not raise_error
    end

    it 'does not raise an exception when confirmation_token is a number' do
      lambda { user.confirm(1) }.should_not raise_error
    end

    it 'does not raise an exception when confirmation_token is an object' do
      lambda { user.confirm(Object.new) }.should_not raise_error
    end

    it 'does not raise an exception when confirmation_token is invalid' do
      lambda { user.confirm("DA@)dafja") }.should_not raise_error
    end

    it 'does not confirm the user if the key is invalid' do
      user.confirmed_at = nil

      user.confirm('invalid key').should be_false
      user.confirmed_at.should be_nil
    end

    it 'returns true if the user is already confirmed' do
      user.confirmed_at = 10.days.ago

      user.confirm(nil).should be_true
    end

    it 'returns false if the confirmation token is invalid' do
      user.confirmed_at = nil
      user.confirmation_token = 'envelope'

      user.confirm(nil).should be_false
    end

    it 'confirm the user if the confirmation token is valid' do
      user.confirmed_at = nil
      user.confirmation_token = 'envelope'

      user.confirm('envelope').should be_true
      user.confirmed_at.should_not be_nil
    end
  end

  describe '#confirmed?' do
    it 'returns true if the user is confirmed' do
      user.confirmed_at = 1.day.ago

      user.confirmed?.should be_true
    end

    it 'returns false if the user is not confirmed' do
      user.confirmed_at = nil
      user.confirmed?.should be_false
    end
  end

  describe '#generate_token!' do
    it 'generates a unique token' do
      expect { user.generate_token!(:confirmation_token) }.to change(user, :confirmation_token)
    end
  end
end
