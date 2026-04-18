FactoryBot.define do
  factory :employee do
    sequence(:employee_code) { |n| "EMP#{n.to_s.rjust(4, '0')}" }
    first_name { 'Asha' }
    middle_name { nil }
    last_name { 'Rao' }
    sequence(:email) { |n| "employee#{n}@example.com" }
    date_of_birth { 30.years.ago.to_date }
    hire_date { 1.year.ago.to_date }
    termination_date { nil }
    employment_type { 'full_time' }
    status { 'active' }
    department
    job_title
  end
end
