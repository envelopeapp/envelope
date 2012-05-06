FactoryGirl.define do
  factory :account do
    association :user
    association :incoming_server
    association :outgoing_server

    name { Faker::Internet.domain_name }
    sequence(:email_address) { |n| "user_#{n}@example.com" }
    reply_to_address { |a| a.email_address }
    imap_directory 'INBOX'
  end

  factory :incoming_server, :class => 'Server' do
    address 'imap.example.com'
    port 993
    ssl true
  end

  factory :outgoing_server, :class => 'Server' do
    address 'smtp.example.com'
    port 465
    ssl true
  end
end