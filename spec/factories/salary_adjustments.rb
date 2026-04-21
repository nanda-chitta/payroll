FactoryBot.define do
  factory :salary_adjustment do
    employee_salary
    employee { employee_salary.employee }
    previous_amount { Faker::Number.decimal(l_digits: 5, r_digits: 2).to_f }
    new_amount { (previous_amount + Faker::Number.decimal(l_digits: 4, r_digits: 2).to_f).round(2) }
    change_amount do
      next nil if previous_amount.nil? || new_amount.nil?

      (new_amount - previous_amount).round(2)
    end
    change_percentage do
      next nil if previous_amount.nil? || new_amount.nil? || previous_amount.zero?

      (((new_amount - previous_amount) / previous_amount) * 100).round(2)
    end
    reason { 'annual_increment' }
    effective_from { Date.current }
    notes { nil }
  end
end
