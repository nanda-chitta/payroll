class Employee < ApplicationRecord
  belongs_to :department
  belongs_to :job_title
end
