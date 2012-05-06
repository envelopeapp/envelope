FactoryGirl.define do
  factory :contact do
    association :user

    prefix { Faker::Name.prefix }
    first_name 'Jeremy'
    last_name 'Contact'
    suffix { Faker::Name.suffix }
  end
end