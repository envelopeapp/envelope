require 'spec_helper'

describe CommonAccountSetting do
  subject { build(:common_account_setting) }

  its(:html_options){ should == {
      :'data-incoming-server-address' => 'imap.example.com',
      :'data-incoming-server-port' => 993,
      :'data-incoming-server-ssl' => true,
      :'data-outgoing-server-address' => 'smtp.example.com',
      :'data-outgoing-server-port' => 587,
      :'data-outgoing-server-ssl' => true,
      :'data-imap-directory' => nil
    }
  }
end
