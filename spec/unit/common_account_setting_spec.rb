require 'spec_helper'

describe CommonAccountSetting do
  before do
    @common_account_setting = create(:common_account_setting, name:'AOL', incoming_server_address:'imap.aol.com', incoming_server_port:993, incoming_server_ssl:true, outgoing_server_address:'smtp.aol.com', outgoing_server_port:587, outgoing_server_ssl:false)
  end

  describe 'html_options' do
    it 'should generate the correct hash' do
      expected = {
        :'data-incoming-server-address' => 'imap.aol.com',
        :'data-incoming-server-port' => 993,
        :'data-incoming-server-ssl' => true,
        :'data-outgoing-server-address' => 'smtp.aol.com',
        :'data-outgoing-server-port' => 587,
        :'data-outgoing-server-ssl' => false,
        :'data-imap-directory' => nil
      }

      @common_account_setting.html_options.should == expected
    end
  end
end