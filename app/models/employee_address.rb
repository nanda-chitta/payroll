class EmployeeAddress < ApplicationRecord
  belongs_to :employee

  normalizes_attributes :address_type, :line1, :city, :postal_code, :country
  normalizes_attributes :line2, :state, blank_to_nil: true

  validates :address_type, presence: true, inclusion: { in: ADDRESS_TYPES }
  validates :line1, presence: true, length: { maximum: 255 }
  validates :line2, length: { maximum: 255 }, allow_blank: true
  validates :city, presence: true, length: { maximum: 100 }
  validates :state, length: { maximum: 100 }, allow_blank: true
  validates :postal_code, presence: true, length: { maximum: 30 }
  validates :country, presence: true, length: { maximum: 100 }
  validates :primary_address,
            uniqueness: {
              scope: :employee_id,
              conditions: -> { where(primary_address: true) },
              message: 'already exists for this employee'
            },
            if: :primary_address?

  scope :primary, -> { where(primary_address: true) }
end
