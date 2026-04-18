class CreateDepartments < ActiveRecord::Migration[8.1]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description

      t.timestamps
    end

    add_index :departments, :name, unique: true
    add_index :departments, :code, unique: true

    add_check_constraint :departments,
                         "char_length(trim(name)) > 0",
                         name: "departments_name_present"

    add_check_constraint :departments,
                         "char_length(trim(code)) > 0",
                         name: "departments_code_present"
  end
end
