FactoryGirl.define do
  factory :phone do
    label 'Home'
    sequence(:phone_number) { |i| i.to_s*10 }
  end
end
