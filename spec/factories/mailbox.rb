FactoryGirl.define do
  factory :mailbox do
    association :account

    sequence(:name) { |n| %w(Inbox Sent Trash Spam Saved My\ Folder)[n%6] }
    location { |m| m.name }
  end
end