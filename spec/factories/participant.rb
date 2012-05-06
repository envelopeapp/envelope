FactoryGirl.define do
  factory :participant do
    association :message

    name 'Bill Participant'
    email_address 'bparticipant@example.com'
    participant_type 'To'

    factory :participant_with_contact do
      association :contact

      name nil
      email_address nil
    end
  end
end