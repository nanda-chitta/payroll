class JobTitle < ApplicationRecord
  has_many :employees, dependent: :restrict_with_exception

  before_validation :normalize_fields

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :code, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }
  validates :description, length: { maximum: 1_000 }, allow_blank: true

  scope :ordered, -> { order(:name) }

  private

  def normalize_fields
    self.name = name.to_s.strip
    self.code = code.to_s.strip.upcase
    self.description = description.to_s.strip.presence
  end
end
