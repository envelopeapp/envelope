FactoryGirl.define do
  factory :email do
    label 'Home'
    sequence(:email_address) do |i|
      if i == 0
        'bparticipant@example.com'
      else
        "bparticipant_#{i}@example.com"
      end
    end
  end
end
