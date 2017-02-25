Sequel.migration do
  change do
    create_table(:students) do
      primary_key :id
      String :student_surname,    :null = false
      String :student_name,       :null = false
      String :student_middlename, :null = true
      TrueClass :is_male,         :null = false
      Fixnum :course,             :null = false
      TrueClass :is_examined,     :null = false
      String :from_university,    :null = false
      String :from_city,          :null = false
      String :from_country,       :null = false
      Fixnum :from_course,        :null = false
      File :photo_path,         :null = true
    end
  end
end
