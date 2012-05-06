FactoryGirl.define do
  factory :email do
    association :contact

    label 'Home'
    email_address 'bill@example.com'
  end
end