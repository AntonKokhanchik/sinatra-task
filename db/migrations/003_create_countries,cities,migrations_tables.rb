Sequel.migration do
  change do
    create_table(:countries) do
      primary_key :id
      String :country_name, :null => false
      TrueClass :is_partner, :default => true
    end


    create_table(:cities) do
      primary_key :id
      String :city_name, :null => false
      foreign_key :country_id, :countries
      TrueClass :is_partner, :default => true
    end

    create_table(:universities) do
      primary_key :id
      String :university_name, :null => false
      foreign_key :city_id, :cities
      TrueClass :is_partner, :default => true
    end
  end
end
