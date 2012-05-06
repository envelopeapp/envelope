FactoryGirl.define do
  factory :common_account_setting do
    name 'AOL'
    incoming_server_address 'imap.aol.com'
    incoming_server_port 993
    incoming_server_ssl true
    outgoing_server_address 'smtp.aol.com'
    outgoing_server_port 587
    outgoing_server_ssl true
  end
end
