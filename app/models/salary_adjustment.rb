class SalaryAdjustment < ApplicationRecord
  belongs_to :employee
  belongs_to :employee_salary

  normalizes_attributes :reason
  normalizes_attributes :notes, blank_to_nil: true
  before_validation :calculate_change_fields

  validates :previous_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :new_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :change_amount, presence: true
  validates :reason, presence: true, inclusion: { in: SALARY_ADJUSTMENT_REASONS }
  validates :effective_from, presence: true

  validate :change_amount_matches_amounts
  validate :employee_matches_salary

  private

  def calculate_change_fields
    return if previous_amount.blank? || new_amount.blank?

    self.change_amount = new_amount - previous_amount
    self.change_percentage = nil if previous_amount.zero?
    return if previous_amount.zero?

    self.change_percentage = ((change_amount / previous_amount) * 100).round(2)
  end

  def change_amount_matches_amounts
    return if previous_amount.blank? || new_amount.blank? || change_amount.blank?
    return if change_amount == new_amount - previous_amount

    errors.add(:change_amount, 'must equal new amount minus previous amount')
  end

  def employee_matches_salary
    return if employee.blank? || employee_salary.blank?
    return if employee_salary.employee_id == employee_id

    errors.add(:employee_salary, 'must belong to the same employee')
  end
end
