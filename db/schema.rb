# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_18_113356) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
    t.index ["name"], name: "index_departments_on_name", unique: true
    t.check_constraint "char_length(TRIM(BOTH FROM code)) > 0", name: "departments_code_present"
    t.check_constraint "char_length(TRIM(BOTH FROM name)) > 0", name: "departments_name_present"
  end

  create_table "employee_addresses", force: :cascade do |t|
    t.string "address_type", default: "home", null: false
    t.string "city", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.bigint "employee_id", null: false
    t.string "line1", null: false
    t.string "line2"
    t.string "postal_code", null: false
    t.boolean "primary_address", default: false, null: false
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["address_type"], name: "index_employee_addresses_on_address_type"
    t.index ["country"], name: "index_employee_addresses_on_country"
    t.index ["employee_id", "address_type"], name: "index_employee_addresses_on_employee_id_and_address_type"
    t.index ["employee_id", "primary_address"], name: "index_employee_addresses_one_primary_per_employee", unique: true, where: "(primary_address = true)"
    t.index ["employee_id"], name: "index_employee_addresses_on_employee_id"
    t.check_constraint "address_type::text = ANY (ARRAY['home'::character varying::text, 'permanent'::character varying::text, 'work'::character varying::text, 'mailing'::character varying::text])", name: "employee_addresses_type_valid"
    t.check_constraint "char_length(TRIM(BOTH FROM city)) > 0", name: "employee_addresses_city_present"
    t.check_constraint "char_length(TRIM(BOTH FROM country)) > 0", name: "employee_addresses_country_present"
    t.check_constraint "char_length(TRIM(BOTH FROM line1)) > 0", name: "employee_addresses_line1_present"
    t.check_constraint "char_length(TRIM(BOTH FROM postal_code)) > 0", name: "employee_addresses_postal_code_present"
  end

  create_table "employee_salaries", force: :cascade do |t|
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.bigint "employee_id", null: false
    t.text "notes"
    t.string "pay_frequency", default: "monthly", null: false
    t.string "reason"
    t.datetime "updated_at", null: false
    t.index ["currency"], name: "index_employee_salaries_on_currency"
    t.index ["effective_to"], name: "index_employee_salaries_on_effective_to"
    t.index ["employee_id", "effective_from"], name: "index_employee_salaries_on_employee_id_and_effective_from", unique: true
    t.index ["employee_id", "effective_to"], name: "index_employee_salaries_on_employee_id_and_effective_to"
    t.index ["employee_id"], name: "index_employee_salaries_on_employee_id"
    t.index ["pay_frequency"], name: "index_employee_salaries_on_pay_frequency"
    t.check_constraint "amount >= 0::numeric", name: "employee_salaries_amount_non_negative"
    t.check_constraint "char_length(TRIM(BOTH FROM currency)) > 0", name: "employee_salaries_currency_present"
    t.check_constraint "effective_to IS NULL OR effective_to >= effective_from", name: "employee_salaries_date_range_valid"
    t.check_constraint "pay_frequency::text = ANY (ARRAY['monthly'::character varying::text, 'yearly'::character varying::text, 'hourly'::character varying::text, 'weekly'::character varying::text])", name: "employee_salaries_pay_frequency_valid"
  end

  create_table "employees", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.bigint "department_id", null: false
    t.string "email", null: false
    t.string "employee_code", null: false
    t.string "employment_type", default: "full_time", null: false
    t.string "first_name", null: false
    t.date "hire_date", null: false
    t.bigint "job_title_id", null: false
    t.string "last_name", null: false
    t.string "middle_name"
    t.string "status", default: "active", null: false
    t.date "termination_date"
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_employees_on_lower_email", unique: true
    t.index ["department_id", "status"], name: "index_employees_on_department_id_and_status"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
    t.index ["employment_type"], name: "index_employees_on_employment_type"
    t.index ["hire_date"], name: "index_employees_on_hire_date"
    t.index ["job_title_id", "status"], name: "index_employees_on_job_title_id_and_status"
    t.index ["job_title_id"], name: "index_employees_on_job_title_id"
    t.index ["status"], name: "index_employees_on_status"
    t.check_constraint "char_length(TRIM(BOTH FROM email)) > 0", name: "employees_email_present"
    t.check_constraint "char_length(TRIM(BOTH FROM employee_code)) > 0", name: "employees_code_present"
    t.check_constraint "char_length(TRIM(BOTH FROM first_name)) > 0", name: "employees_first_name_present"
    t.check_constraint "char_length(TRIM(BOTH FROM last_name)) > 0", name: "employees_last_name_present"
    t.check_constraint "employment_type::text = ANY (ARRAY['full_time'::character varying::text, 'part_time'::character varying::text, 'contract'::character varying::text, 'intern'::character varying::text])", name: "employees_employment_type_valid"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text, 'terminated'::character varying::text, 'on_leave'::character varying::text])", name: "employees_status_valid"
    t.check_constraint "termination_date IS NULL OR termination_date >= hire_date", name: "employees_termination_date_valid"
  end

  create_table "job_titles", force: :cascade do |t|
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_job_titles_on_code", unique: true
    t.index ["name"], name: "index_job_titles_on_name", unique: true
    t.check_constraint "char_length(TRIM(BOTH FROM code)) > 0", name: "job_titles_code_present"
    t.check_constraint "char_length(TRIM(BOTH FROM name)) > 0", name: "job_titles_name_present"
  end

  create_table "salary_adjustments", force: :cascade do |t|
    t.decimal "change_amount", precision: 12, scale: 2, null: false
    t.decimal "change_percentage", precision: 8, scale: 2
    t.datetime "created_at", null: false
    t.date "effective_from", null: false
    t.bigint "employee_id", null: false
    t.bigint "employee_salary_id", null: false
    t.decimal "new_amount", precision: 12, scale: 2, null: false
    t.text "notes"
    t.decimal "previous_amount", precision: 12, scale: 2, null: false
    t.string "reason", null: false
    t.datetime "updated_at", null: false
    t.index ["effective_from"], name: "index_salary_adjustments_on_effective_from"
    t.index ["employee_id", "effective_from"], name: "index_salary_adjustments_on_employee_id_and_effective_from"
    t.index ["employee_id"], name: "index_salary_adjustments_on_employee_id"
    t.index ["employee_salary_id"], name: "index_salary_adjustments_on_employee_salary_id"
    t.index ["reason"], name: "index_salary_adjustments_on_reason"
    t.check_constraint "change_amount = (new_amount - previous_amount)", name: "salary_adjustments_change_amount_valid"
    t.check_constraint "new_amount >= 0::numeric", name: "salary_adjustments_new_amount_non_negative"
    t.check_constraint "previous_amount >= 0::numeric", name: "salary_adjustments_previous_amount_non_negative"
    t.check_constraint "reason::text = ANY (ARRAY['annual_increment'::character varying::text, 'promotion'::character varying::text, 'correction'::character varying::text, 'market_adjustment'::character varying::text, 'demotion'::character varying::text, 'other'::character varying::text])", name: "salary_adjustments_reason_valid"
  end

  add_foreign_key "employee_addresses", "employees", on_delete: :cascade
  add_foreign_key "employee_salaries", "employees", on_delete: :cascade
  add_foreign_key "employees", "departments", on_delete: :restrict
  add_foreign_key "employees", "job_titles", on_delete: :restrict
  add_foreign_key "salary_adjustments", "employee_salaries", on_delete: :cascade
  add_foreign_key "salary_adjustments", "employees", on_delete: :cascade
end
