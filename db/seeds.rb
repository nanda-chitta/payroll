BATCH_SIZE = 1_000
EMPLOYEE_COUNT = 10_000
NOW = Time.current

departments = [
  [ 'People Operations', 'PEOPLE' ],
  [ 'Engineering', 'ENG' ],
  [ 'Finance', 'FIN' ],
  [ 'Sales', 'SALES' ],
  [ 'Customer Success', 'CS' ],
  [ 'Marketing', 'MKT' ],
  [ 'Legal', 'LEGAL' ],
  [ 'Operations', 'OPS' ]
]

job_titles = [
  [ 'HR Manager', 'HRM' ],
  [ 'Software Engineer', 'SWE' ],
  [ 'Senior Software Engineer', 'SSWE' ],
  [ 'Engineering Manager', 'EM' ],
  [ 'Account Executive', 'AE' ],
  [ 'Financial Analyst', 'FA' ],
  [ 'Customer Success Manager', 'CSM' ],
  [ 'Marketing Specialist', 'MS' ],
  [ 'Operations Analyst', 'OA' ],
  [ 'Legal Counsel', 'LC' ]
]

countries = [
  'India',
  'United States',
  'Canada',
  'United Kingdom',
  'Germany',
  'Australia',
  'Singapore',
  'Brazil'
]

def seed_names(file_name)
  Rails.root.join('db', 'seed_data', file_name).readlines(chomp: true).reject(&:blank?)
end

def insert_in_batches(model, rows)
  rows.each_slice(BATCH_SIZE) { |batch| model.insert_all(batch) }
end

first_names = seed_names('first_names.txt')
last_names = seed_names('last_names.txt')

raise 'first_names.txt and last_names.txt must contain at least one value' if first_names.blank? || last_names.blank?

ActiveRecord::Base.transaction do
  ActiveRecord::Base.connection.execute(
    'TRUNCATE TABLE salary_adjustments, employee_salaries, employee_addresses, employees RESTART IDENTITY CASCADE'
  )

  Department.upsert_all(
    departments.map do |name, code|
      { name:, code:, description: "#{name} department", created_at: NOW, updated_at: NOW }
    end,
    unique_by: :index_departments_on_code
  )

  JobTitle.upsert_all(
    job_titles.map do |name, code|
      { name:, code:, description: "#{name} role", created_at: NOW, updated_at: NOW }
    end,
    unique_by: :index_job_titles_on_code
  )

  department_ids = Department.order(:code).pluck(:id)
  job_title_ids = JobTitle.order(:code).pluck(:id)
  job_title_salary_floor = job_title_ids.each_with_index.to_h { |id, index| [ id, 45_000 + (index * 8_000) ] }

  employee_rows = Array.new(EMPLOYEE_COUNT) do |index|
    first_name = first_names[index % first_names.length]
    last_name = last_names[(index / first_names.length) % last_names.length]

    {
      employee_code: "EMP#{(index + 1).to_s.rjust(5, '0')}",
      first_name:,
      middle_name: nil,
      last_name:,
      email: "employee#{index + 1}@example.com",
      date_of_birth: Date.new(1965 + (index % 35), (index % 12) + 1, (index % 27) + 1),
      hire_date: Date.current - (index % 2_500).days,
      termination_date: nil,
      employment_type: EMPLOYMENT_TYPES[index % EMPLOYMENT_TYPES.length],
      status: index % 97 == 0 ? 'on_leave' : 'active',
      department_id: department_ids[index % department_ids.length],
      job_title_id: job_title_ids[index % job_title_ids.length],
      created_at: NOW,
      updated_at: NOW
    }
  end

  insert_in_batches(Employee, employee_rows)

  employees = Employee.order(:employee_code).pluck(:id, :employee_code, :job_title_id, :hire_date)

  address_rows = employees.each_with_index.map do |(employee_id, _code, _job_title_id, _hire_date), index|
    country = countries[index % countries.length]

    {
      employee_id:,
      address_type: 'home',
      line1: "#{100 + index} Market Street",
      line2: nil,
      city: "#{country} City #{(index % 25) + 1}",
      state: nil,
      postal_code: (100_000 + index).to_s,
      country:,
      primary_address: true,
      created_at: NOW,
      updated_at: NOW
    }
  end

  salary_rows = employees.each_with_index.map do |(employee_id, _code, job_title_id, hire_date), index|
    base = job_title_salary_floor.fetch(job_title_id)
    country_multiplier = 1 + ((index % countries.length) * 0.06)
    tenure_component = (index % 12) * 1_500
    amount = ((base * country_multiplier) + tenure_component).round(2)

    {
      employee_id:,
      amount:,
      currency: 'USD',
      pay_frequency: 'yearly',
      effective_from: hire_date,
      effective_to: nil,
      reason: 'Seeded baseline salary',
      notes: nil,
      created_at: NOW,
      updated_at: NOW
    }
  end

  insert_in_batches(EmployeeAddress, address_rows)
  insert_in_batches(EmployeeSalary, salary_rows)
end

puts "Seeded #{Department.count} departments, #{JobTitle.count} job titles, and #{Employee.count} employees."
