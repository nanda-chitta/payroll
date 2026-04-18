class CreateJobTitles < ActiveRecord::Migration[8.1]
  def change
    create_table :job_titles do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description

      t.timestamps
    end

    add_index :job_titles, :name, unique: true
    add_index :job_titles, :code, unique: true

    add_check_constraint :job_titles,
                         "char_length(trim(name)) > 0",
                         name: "job_titles_name_present"

    add_check_constraint :job_titles,
                         "char_length(trim(code)) > 0",
                         name: "job_titles_code_present"
  end
end
