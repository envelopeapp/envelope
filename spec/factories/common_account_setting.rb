FactoryGirl.define do
  factory :common_account_setting do
    name 'AOL'
    incoming_server {{
      address: 'imap.example.com',
      port: 993,
      ssl: true,
    }}
    outgoing_server {{
      address: 'smtp.example.com',
      port: 587,
      ssl: true,
    }}
  end
end
