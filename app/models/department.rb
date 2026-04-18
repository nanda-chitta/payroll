class Department < ApplicationRecord
  has_many :employees, dependent: :restrict_with_exception

  normalizes_attributes :name
  normalizes_attributes :code, transform: :upcase
  normalizes_attributes :description, blank_to_nil: true

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :code, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }
  validates :description, length: { maximum: 1_000 }, allow_blank: true

  scope :ordered, -> { order(:name) }
end
