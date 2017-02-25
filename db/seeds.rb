# в этом файле мы через транзакции последовательно заполняем БД случайными данными

# подключаем гем фейкер
require 'faker'

DB.transaction do
  5.times do |n|
    old_course = rand(2..4)
    DB[:students].insert( {
      :student_surname => Faker::Name.last_name,
      :student_name => Faker::Name.first_name,
      :student_middlename => Faker::Name.first_name,
      :is_male => if(rand(0..1) == 1) then true else false end,
      :course => old_course + rand(-1..1),
      :is_examined => if(rand(0..4) == 0) then false else true end,
      :from_university => Faker::Educator.university,
      :from_city => Faker::Address.city,
      :from_country => Faker::Address.country,
      :from_course => old_course,
      :photo => Faker::Avatar.image(slug = nil, size = '128x128', format = 'png', set = 'students_photos', bgset = nil),
    } )
  end
end
