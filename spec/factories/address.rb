FactoryGirl.define do
  factory :address do
    label 'Home'
    sequence(:line_1) { |i| i.to_s*3 + ' Some Street' }
    city 'Pittsburgh'
    state 'PA'
    country 'United States of America'
    zip_code '15213'
  end
end
