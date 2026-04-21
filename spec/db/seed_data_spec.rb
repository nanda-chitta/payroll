require 'rails_helper'

RSpec.describe 'seed data' do
  def seed_names(file_name)
    Rails.root.join('db/seed_data', file_name).readlines(chomp: true).reject(&:blank?)
  end

  it 'provides enough unique names for 10,000 unique full-name combinations' do
    first_names = seed_names('first_names.txt')
    last_names = seed_names('last_names.txt')

    expect(first_names.uniq.size).to be >= 100
    expect(last_names.uniq.size).to be >= 100
    expect(first_names.uniq.size * last_names.uniq.size).to be >= 10_000
  end

  it 'loads a deterministic 10,000 employee dataset with expected distributions' do
    load Rails.root.join('db/seeds.rb')

    expect(Department.count).to eq(8)
    expect(JobTitle.count).to eq(10)
    expect(Employee.count).to eq(10_000)
    expect(EmployeeAddress.count).to eq(10_000)
    expect(EmployeeSalary.count).to eq(10_000)
    expect(Employee.distinct.count(:employee_code)).to eq(10_000)
    expect(Employee.pluck(:first_name, :last_name).uniq.size).to eq(10_000)
    expect(Department.joins(:employees).group(:code).count.values).to all(eq(1_250))
    expect(JobTitle.joins(:employees).group(:code).count.values).to all(eq(1_000))
    expect(EmployeeAddress.where(primary_address: true).group(:country).count.values).to all(eq(1_250))
  end
end
