FactoryGirl.define do
  factory :contact do
    prefix { Faker::Name.prefix }
    first_name 'Jeremy'
    last_name 'Contact'
    suffix { Faker::Name.suffix }

    emails {[
      FactoryGirl.build(:email),
      FactoryGirl.build(:email),
      FactoryGirl.build(:email)
    ]}

    phones {[
      FactoryGirl.build(:phone),
      FactoryGirl.build(:phone),
      FactoryGirl.build(:phone)
    ]}
  end
end
