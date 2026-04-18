FactoryBot.define do
  factory :salary_adjustment do
    employee_salary
    employee { employee_salary.employee }
    previous_amount { 75_000.00 }
    new_amount { 82_500.00 }
    change_amount { 7_500.00 }
    change_percentage { 10.00 }
    reason { 'annual_increment' }
    effective_from { Date.current }
    notes { nil }
  end
end
