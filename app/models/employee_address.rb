class EmployeeAddress < ApplicationRecord
  belongs_to :employee

  before_validation :normalize_fields

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

  private

  def normalize_fields
    self.address_type = address_type.to_s.strip
    self.line1 = line1.to_s.strip
    self.line2 = line2.to_s.strip.presence
    self.city = city.to_s.strip
    self.state = state.to_s.strip.presence
    self.postal_code = postal_code.to_s.strip
    self.country = country.to_s.strip
  end
end
