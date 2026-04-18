class Employee < ApplicationRecord
  belongs_to :department
  belongs_to :job_title

  has_many :employee_addresses, dependent: :destroy
  has_many :employee_salaries, dependent: :destroy
  has_many :salary_adjustments, dependent: :destroy

  normalizes_attributes :employee_code, transform: :upcase
  normalizes_attributes :first_name, :last_name, :employment_type, :status
  normalizes_attributes :middle_name, blank_to_nil: true
  normalizes_attributes :email, transform: :downcase

  validates :employee_code, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }
  validates :first_name, presence: true, length: { maximum: 100 }
  validates :middle_name, length: { maximum: 100 }, allow_blank: true
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: 255 },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :hire_date, presence: true
  validates :date_of_birth, comparison: { less_than: -> { Date.current } }, allow_blank: true
  validates :employment_type, presence: true, inclusion: { in: EMPLOYMENT_TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }

  validate :termination_date_not_before_hire_date
  validate :date_of_birth_reasonable

  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :terminated, -> { where(status: 'terminated') }
  scope :ordered, -> { order(:first_name, :last_name) }

  def full_name
    [ first_name, middle_name, last_name ].compact_blank.join(' ')
  end

  def current_address
    employee_addresses.find_by(primary_address: true) || employee_addresses.order(created_at: :desc).first
  end

  def current_salary
    employee_salaries
      .where('effective_from <= ?', Date.current)
      .where('effective_to IS NULL OR effective_to >= ?', Date.current)
      .order(effective_from: :desc)
      .first
  end

  private

  def termination_date_not_before_hire_date
    return if termination_date.blank? || hire_date.blank?
    return if termination_date >= hire_date

    errors.add(:termination_date, 'must be on or after hire date')
  end

  def date_of_birth_reasonable
    return if date_of_birth.blank?
    return if date_of_birth > 100.years.ago.to_date && date_of_birth < Date.current

    errors.add(:date_of_birth, 'is not within a reasonable range')
  end
end
