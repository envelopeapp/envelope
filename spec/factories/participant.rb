FactoryGirl.define do
  factory :participant do
    name 'Bill Participant'
    email_address 'bparticipant@example.com'
    participant_type 'To'

    factory :participant_with_contact do
      name nil
      email_address nil

      contact { FactoryGirl.build(:contact) }
    end
  end
end
