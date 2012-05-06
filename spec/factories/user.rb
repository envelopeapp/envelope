FactoryGirl.define do
  factory :user do
    first_name 'Bill'
    last_name 'Jones'

    sequence(:username) { |n| "user_#{n}" }
    password 'secret'
    password_confirmation {|u| u.password}

    sequence(:email_address) { |n| "user_#{n}@example.com" }
  end
end