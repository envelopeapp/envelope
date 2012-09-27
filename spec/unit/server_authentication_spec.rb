require 'spec_helper'

describe ServerAuthentication do
  before(:all) do
    @server = build(:server)
    @server_authentication = build(:server_authentication, server: @server)
    @encryptor = @server_authentication.send(:encryptor)
  end

  # associations
  it { should be_embedded_in(:server) }

  # validations
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
  end

  describe 'password' do
    it 'should return the correct unencrypted password' do
      encrypted_password = @server_authentication.encrypted_password
      password = @encryptor.decrypt_and_verify(encrypted_password)

      @server_authentication.password.should == password
    end
  end
end
