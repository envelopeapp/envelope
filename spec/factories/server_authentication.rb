FactoryGirl.define do
  factory :server_authentication do
    association :server

    username 'username@example.com'
    password 'secret'
  end
end