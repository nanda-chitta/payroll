FactoryBot.define do
  factory :job_title do
    sequence(:name) { |n| "Job Title #{n}" }
    sequence(:code) { |n| "JT#{n}" }
    description { 'Job title description' }
  end
end
