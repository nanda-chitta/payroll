class SalaryAdjustment < ApplicationRecord
  belongs_to :employee
  belongs_to :employee_salary
end
