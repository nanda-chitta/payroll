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

ActiveRecord::Schema[8.1].define(version: 2026_04_18_111528) do
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

  create_table "employees", force: :cascade do |t|
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "currency", default: "USD", null: false
    t.string "department", null: false
    t.string "email", null: false
    t.string "employee_code", null: false
    t.string "employment_type", default: "full_time", null: false
    t.string "first_name", null: false
    t.date "hire_date", null: false
    t.string "job_title", null: false
    t.string "last_name", null: false
    t.decimal "salary", precision: 12, scale: 2, null: false
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["country", "job_title"], name: "index_employees_on_country_and_job_title"
    t.index ["country", "status"], name: "index_employees_on_country_and_status"
    t.index ["country"], name: "index_employees_on_country"
    t.index ["department"], name: "index_employees_on_department"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
    t.index ["job_title"], name: "index_employees_on_job_title"
    t.index ["status"], name: "index_employees_on_status"
    t.check_constraint "employment_type::text = ANY (ARRAY['full_time'::character varying::text, 'part_time'::character varying::text, 'contract'::character varying::text, 'intern'::character varying::text])", name: "employees_employment_type_valid"
    t.check_constraint "salary >= 0::numeric", name: "employees_salary_non_negative"
    t.check_constraint "status::text = ANY (ARRAY['active'::character varying::text, 'inactive'::character varying::text, 'terminated'::character varying::text])", name: "employees_status_valid"
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
end
