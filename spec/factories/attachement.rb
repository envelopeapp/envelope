FactoryGirl.define do
  factory :attachment do
    sequence(:filename){ |i| "file_#{i}" }
    path '/tmp/file'
  end
end
