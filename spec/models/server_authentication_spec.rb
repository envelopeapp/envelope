require 'spec_helper'

describe ServerAuthentication do
  subject { build(:server_authentication, server: build(:server)) }

  # associations
  it { should be_embedded_in(:server) }

  # validations
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:password) }

  # methods
  context 'encryption' do
    let(:server_authentication) { subject }

    describe '#password=' do
      it 'encrypts the password as base64' do
        server_authentication.password = 'testing'
        server_authentication.encrypted_password.should == "H+XlEZVLgjuOzZgb9/b9qg==\n"
      end
    end

    describe '#password' do
      it 'should return the correct unencrypted password' do
        encrypted_password = server_authentication.encrypted_password
        password = Base64.decode64(Base64.decode64(encrypted_password).decrypt)

        server_authentication.password.should == password
      end
    end
  end
end
