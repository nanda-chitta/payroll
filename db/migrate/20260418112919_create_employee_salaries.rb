class CreateEmployeeSalaries < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_salaries do |t|
      t.references :employee, null: false, foreign_key: { on_delete: :cascade }
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, null: false, default: "USD"
      t.string :pay_frequency, null: false, default: "monthly"
      t.date :effective_from, null: false
      t.date :effective_to
      t.string :reason
      t.text :notes

      t.timestamps
    end

    add_index :employee_salaries, [:employee_id, :effective_from], unique: true
    add_index :employee_salaries, :currency
    add_index :employee_salaries, :pay_frequency
    add_index :employee_salaries, :effective_to
    add_index :employee_salaries, [:employee_id, :effective_to]

    add_check_constraint :employee_salaries,
                         "amount >= 0",
                         name: "employee_salaries_amount_non_negative"

    add_check_constraint :employee_salaries,
                         "char_length(trim(currency)) > 0",
                         name: "employee_salaries_currency_present"

    add_check_constraint :employee_salaries,
                         "pay_frequency IN ('monthly', 'yearly', 'hourly', 'weekly')",
                         name: "employee_salaries_pay_frequency_valid"

    add_check_constraint :employee_salaries,
                         "effective_to IS NULL OR effective_to >= effective_from",
                         name: "employee_salaries_date_range_valid"
  end
end
