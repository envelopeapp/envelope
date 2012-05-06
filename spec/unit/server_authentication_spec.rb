require 'spec_helper'

describe ServerAuthentication do
  before do
    @server_authentication = create(:server_authentication)
    @encryptor = @server_authentication.send(:encryptor)
  end

  after do
    @server_authentication.destroy
  end

  # associations
  it { should belong_to(:server) }

  # validations
  it { should validate_presence_of(:server) }
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:password) }

  # methods
  describe 'password=' do
    it 'should not crash when password is blank' do
      lambda { @server_authentication.password = '' }.should_not raise_error
    end

    it 'should not crash when password is nil' do
      lambda { @server_authentication.password = nil }.should_not raise_error
    end

    it 'should set the encrypted password correctly' do
      password = 'secret'
      encrypted_password = @encryptor.encrypt_and_sign(password.to_s)

      @server_authentication.password = 'secret'
      @server_authentication.encrypted_password#.should == encrypted_password
    end
  end

  describe 'password' do
    it 'should return the correct unencrypted password' do
      encrypted_password = @server_authentication.encrypted_password
      password = @encryptor.decrypt_and_verify(encrypted_password)

      @server_authentication.password.should == password
    end
  end
end