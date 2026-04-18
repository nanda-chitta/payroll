FactoryBot.define do
  factory :salary_adjustment do
    employee { nil }
    employee_salary { nil }
    previous_amount { "9.99" }
    new_amount { "9.99" }
    change_amount { "9.99" }
    change_percentage { "9.99" }
    reason { "MyString" }
    effective_from { "2026-04-18" }
    notes { "MyText" }
  end
end
