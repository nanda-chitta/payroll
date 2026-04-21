FactoryBot.define do
  factory :job_title do
    sequence(:name) { |n| "#{Faker::Job.position} #{n}" }
    sequence(:code) { |n| "JOB#{n}" }
    description { Faker::Lorem.sentence(word_count: 5) }
  end
end
