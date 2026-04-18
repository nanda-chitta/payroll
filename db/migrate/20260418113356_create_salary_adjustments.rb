class CreateSalaryAdjustments < ActiveRecord::Migration[8.1]
  def change
    create_table :salary_adjustments do |t|
      t.references :employee, null: false, foreign_key: { on_delete: :cascade }
      t.references :employee_salary, null: false, foreign_key: { on_delete: :cascade }

      t.decimal :previous_amount, precision: 12, scale: 2, null: false
      t.decimal :new_amount, precision: 12, scale: 2, null: false
      t.decimal :change_amount, precision: 12, scale: 2, null: false
      t.decimal :change_percentage, precision: 8, scale: 2
      t.string :reason, null: false
      t.date :effective_from, null: false
      t.text :notes

      t.timestamps
    end

    add_index :salary_adjustments, :effective_from
    add_index :salary_adjustments, :reason
    add_index :salary_adjustments, [:employee_id, :effective_from]

    add_check_constraint :salary_adjustments,
                         "previous_amount >= 0",
                         name: "salary_adjustments_previous_amount_non_negative"

    add_check_constraint :salary_adjustments,
                         "new_amount >= 0",
                         name: "salary_adjustments_new_amount_non_negative"

    add_check_constraint :salary_adjustments,
                         "change_amount = (new_amount - previous_amount)",
                         name: "salary_adjustments_change_amount_valid"

    add_check_constraint :salary_adjustments,
                         "reason IN ('annual_increment', 'promotion', 'correction', 'market_adjustment', 'demotion', 'other')",
                         name: "salary_adjustments_reason_valid"
  end
end
