require 'spec_helper'

describe User do
  before do
    @user = create(:user, first_name:'Seth', last_name:'Vargo')
  end

  after do
    @user.destroy
  end

  # assocations
  it { should have_many(:accounts) }
  it { should have_many(:mailboxes).through(:accounts) }
  it { should have_many(:messages).through(:mailboxes) }

  # unified mailboxes
  it { should have_many(:inbox_mailboxes).through(:accounts) }
    it { should have_many(:inbox_messages).through(:inbox_mailboxes) }
  it { should have_many(:sent_mailboxes).through(:accounts) }
    it { should have_many(:sent_messages).through(:sent_mailboxes) }
  it { should have_many(:trash_mailboxes).through(:accounts) }
    it { should have_many(:trash_messages).through(:trash_mailboxes) }

  it { should have_many(:labels) }
  it { should have_many(:contacts) }
  it { should have_many(:contact_emails).through(:contacts) }

  # validations
  it { should validate_uniqueness_of(:username) }
  it { should validate_uniqueness_of(:email_address) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:email_address) }
  it { should validate_confirmation_of(:password) }

  # methods
  describe 'name' do
    it 'should set the correct first_name' do
      @user.first_name.should == 'Seth'
    end

    it 'should set the correct last_name' do
      @user.last_name.should == 'Vargo'
    end
  end

  describe 'name=' do
    it 'should set the correct first_nane' do
      name = 'Sample User'
      @user.name = name
      split_name = name.split(' ', 2)

      @user.first_name.should == split_name[0]
      @user.last_name.should == split_name[1]
    end
  end

  describe 'queue_name' do
    it 'should be the SHA1 of id, name, created_at, and updated_at' do
      tmp = [@user.id, @user.name, @user.created_at, @user.updated_at].join('/')
      digest = Digest::SHA1.hexdigest(tmp)
      @user.queue_name.should == ['', digest].join('/')
    end
  end

  describe 'confirm' do
    it 'should never raise an exception when confirmation_token is nil' do
      lambda { @user.confirm(nil) }.should_not raise_error
    end

    it 'should never raise an exception when confirmation_token is a number' do
      lambda { @user.confirm(1) }.should_not raise_error
    end

    it 'should never raise an exception when confirmation_token is an object' do
      lambda { @user.confirm(Object.new) }.should_not raise_error
    end

    it 'should never raise an exception when confirmation_token is invalid' do
      lambda { @user.confirm("DA@)dafja") }.should_not raise_error
    end

    it 'should not confirm the user if the key is invalid' do
      @user.update_attribute(:confirmed_at, nil)

      @user.confirm('invalid key').should be_false
      @user.confirmed_at.should be_nil
    end

    it 'should return true if the user is already confirmed' do
      @user.confirmed_at = 10.days.ago
      @user.confirm(nil).should == true
    end

    it 'should return false if the confirmation token is invalid' do
      @user.confirmed_at = nil
      @user.confirmation_token = 'envelope'
      @user.confirm(nil).should == false
    end

    it 'should confirm the user if the confirmation token is valid' do
      @user.confirmed_at = nil
      @user.confirmation_token = 'envelope'

      @user.confirm('envelope').should be_true
      @user.confirmed_at.should_not be_nil
    end
  end

  describe 'confirmed?' do
    it 'should return true if the user is confirmed' do
      @user.update_attribute(:confirmed_at, 1.day.ago)
      @user.confirmed?.should be_true
    end

    it 'should return false if the user is not confirmed' do
      @user.update_attribute(:confirmed_at, nil)
      @user.confirmed?.should be_false
    end
  end

  describe 'reset_password!' do
    it 'should enqueue a job for password reset' do
      expect {
        @user.reset_password!
      }.to change(Delayed::Job, :count).by(1)
    end

    it 'should run the delayed_job process' do
      expect {
        Delayed::Worker.new.work_off
      }.to change(Delayed::Job, :count).by(-2)
    end
  end

  describe 'generate_token!' do
    it 'should generate a unique token' do
      expect { @user.generate_token!(:confirmation_token) }.to change(@user, :confirmation_token)
    end
  end

  describe 'send_confirmation_email' do
    it 'should send a confirmation email' do
      expect {
        @user.send(:send_confirmation_email)
      }.to change(Delayed::Job, :count).by(1)
    end

    it 'should run the delayed_job process' do
      expect {
        Delayed::Worker.new.work_off
      }.to change(Delayed::Job, :count).by(-2)
    end
  end
end
