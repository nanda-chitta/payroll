FactoryBot.define do
  factory :employee do
    employee_code { "MyString" }
    first_name { "MyString" }
    middle_name { "MyString" }
    last_name { "MyString" }
    email { "MyString" }
    date_of_birth { "2026-04-18" }
    hire_date { "2026-04-18" }
    termination_date { "2026-04-18" }
    employment_type { "MyString" }
    status { "MyString" }
    department { nil }
    job_title { nil }
  end
end
