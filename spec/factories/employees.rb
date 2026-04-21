FactoryBot.define do
  factory :employee do
    sequence(:employee_code) { |n| "EMP#{n.to_s.rjust(4, '0')}" }
    first_name { Faker::Name.first_name }
    middle_name { nil }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "#{Faker::Internet.unique.username(specifier: [ first_name, last_name ]).downcase}#{n}@example.com" }
    date_of_birth { Faker::Date.birthday(min_age: 21, max_age: 65) }
    hire_date { Faker::Date.backward(days: 365 * 5) }
    termination_date { nil }
    employment_type { 'full_time' }
    status { 'active' }
    department
    job_title
  end
end
