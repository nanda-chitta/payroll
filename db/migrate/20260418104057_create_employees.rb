class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string  :employee_code, null: false
      t.string  :first_name, null: false
      t.string  :last_name, null: false
      t.string  :email, null: false
      t.string  :job_title, null: false
      t.string  :department, null: false
      t.string  :country, null: false
      t.string  :currency, null: false, default: 'USD'
      t.decimal :salary, precision: 12, scale: 2, null: false
      t.date    :hire_date, null: false
      t.string  :employment_type, null: false, default: 'full_time'
      t.string  :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :employees, :employee_code, unique: true
    add_index :employees, :email, unique: true
    add_index :employees, :country
    add_index :employees, :job_title
    add_index :employees, :department
    add_index :employees, :status
    add_index :employees, [:country, :job_title]
    add_index :employees, [:country, :status]

    add_check_constraint :employees, 'salary >= 0', name: 'employees_salary_non_negative'
    add_check_constraint :employees,
                         "employment_type IN ('full_time', 'part_time', 'contract', 'intern')",
                         name: 'employees_employment_type_valid'
    add_check_constraint :employees,
                         "status IN ('active', 'inactive', 'terminated')",
                         name: 'employees_status_valid'
  end
end
