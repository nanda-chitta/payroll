class EmployeeSalary < ApplicationRecord
  belongs_to :employee

  before_validation :normalize_fields

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :pay_frequency, presence: true, inclusion: { in: PAY_FREQUENCIES }
  validates :effective_from, presence: true
  validates :effective_from, uniqueness: { scope: :employee_id }, if: :employee_id

  validate :effective_to_not_before_effective_from

  scope :current, lambda {
    where('effective_from <= ?', Date.current)
      .where('effective_to IS NULL OR effective_to >= ?', Date.current)
  }

  private

  def normalize_fields
    self.currency = currency.to_s.strip.upcase
    self.pay_frequency = pay_frequency.to_s.strip
    self.reason = reason.to_s.strip.presence
    self.notes = notes.to_s.strip.presence
  end

  def effective_to_not_before_effective_from
    return if effective_to.blank? || effective_from.blank?
    return if effective_to >= effective_from

    errors.add(:effective_to, 'must be on or after effective from')
  end
end
