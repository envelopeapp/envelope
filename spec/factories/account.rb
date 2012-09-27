FactoryGirl.define do
  factory :account do
    association :user

    name { Faker::Internet.domain_name }
    sequence(:email_address) { |n| "user_#{n}@example.com" }
    reply_to_address { |a| a.email_address }
    imap_directory 'INBOX'

    incoming_server { FactoryGirl.build(:server) }
    outgoing_server { FactoryGirl.build(:server) }
  end
end
