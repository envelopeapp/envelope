FactoryGirl.define do
  factory :message do
    association :mailbox

    message_id { "<message-#{Digest::SHA1.hexdigest(Random.new.rand(1000).to_s).downcase}@example.com>" }
    uid { Random.new.rand(1000) }
    subject { Faker::Company.catch_phrase }
    date 5.days.ago
    read true
    downloaded true
    text_part { Faker::Lorem.paragraphs(3) }
    preview { Faker::Lorem.sentences(2) }
    raw { Faker::Lorem.paragraphs(5) }

    participants { [
      FactoryGirl.build(:participant),
      FactoryGirl.build(:participant_with_contact)
    ] }
  end
end
