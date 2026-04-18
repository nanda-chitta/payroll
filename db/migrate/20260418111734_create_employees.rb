class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :employee_code, null: false
      t.string :first_name, null: false
      t.string :middle_name
      t.string :last_name, null: false
      t.string :email, null: false
      t.date :date_of_birth
      t.date :hire_date, null: false
      t.date :termination_date
      t.string :employment_type, null: false, default: "full_time"
      t.string :status, null: false, default: "active"

      t.references :department, null: false, foreign_key: { on_delete: :restrict }
      t.references :job_title, null: false, foreign_key: { on_delete: :restrict }

      t.timestamps
    end

    add_index :employees, :employee_code, unique: true
    add_index :employees, "LOWER(email)", unique: true, name: "index_employees_on_lower_email"
    add_index :employees, :status
    add_index :employees, :employment_type
    add_index :employees, :hire_date
    add_index :employees, [:department_id, :status]
    add_index :employees, [:job_title_id, :status]

    add_check_constraint :employees,
                         "char_length(trim(employee_code)) > 0",
                         name: "employees_code_present"

    add_check_constraint :employees,
                         "char_length(trim(first_name)) > 0",
                         name: "employees_first_name_present"

    add_check_constraint :employees,
                         "char_length(trim(last_name)) > 0",
                         name: "employees_last_name_present"

    add_check_constraint :employees,
                         "char_length(trim(email)) > 0",
                         name: "employees_email_present"

    add_check_constraint :employees,
                         "employment_type IN ('full_time', 'part_time', 'contract', 'intern')",
                         name: "employees_employment_type_valid"

    add_check_constraint :employees,
                         "status IN ('active', 'inactive', 'terminated', 'on_leave')",
                         name: "employees_status_valid"

    add_check_constraint :employees,
                         "termination_date IS NULL OR termination_date >= hire_date",
                         name: "employees_termination_date_valid"
  end
end
