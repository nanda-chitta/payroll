class CreateEmployeeAddresses < ActiveRecord::Migration[8.1]
  def change
    create_table :employee_addresses do |t|
      t.references :employee, null: false, foreign_key: { on_delete: :cascade }
      t.string :address_type, null: false, default: "home"
      t.string :line1, null: false
      t.string :line2
      t.string :city, null: false
      t.string :state
      t.string :postal_code, null: false
      t.string :country, null: false
      t.boolean :primary_address, null: false, default: false

      t.timestamps
    end

    add_index :employee_addresses, :address_type
    add_index :employee_addresses, :country
    add_index :employee_addresses, [:employee_id, :address_type]
    add_index :employee_addresses,
              [:employee_id, :primary_address],
              unique: true,
              where: "primary_address = true",
              name: "index_employee_addresses_one_primary_per_employee"

    add_check_constraint :employee_addresses,
                         "address_type IN ('home', 'permanent', 'work', 'mailing')",
                         name: "employee_addresses_type_valid"

    add_check_constraint :employee_addresses,
                         "char_length(trim(line1)) > 0",
                         name: "employee_addresses_line1_present"

    add_check_constraint :employee_addresses,
                         "char_length(trim(city)) > 0",
                         name: "employee_addresses_city_present"

    add_check_constraint :employee_addresses,
                         "char_length(trim(postal_code)) > 0",
                         name: "employee_addresses_postal_code_present"

    add_check_constraint :employee_addresses,
                         "char_length(trim(country)) > 0",
                         name: "employee_addresses_country_present"
  end
end
