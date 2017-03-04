Sequel.migration do
  change do
    drop_column :students, :from_city
    drop_column :students, :from_country
    drop_column :students, :from_university
    
    alter_table(:students) do
      add_foreign_key :university_id, :universities
    end
  end
end
