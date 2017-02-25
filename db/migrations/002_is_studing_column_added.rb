Sequel.migration do
  change do
    alter_table(:students) do
      add_column :is_studing, TrueClass, :default => true
    end
  end
end
