# в этом файле мы через транзакции последовательно заполняем БД случайными данными

# подключаем гем фейкер
require 'faker'

DB.transaction do
  5.times do |n|
    DB[:students].insert( {
      :student_surname => Faker::Name.last_name
      :student_name => Faker::Name.first_name,
      :student_middlename => Faker::Name.first_name,
      :is_male => if(random(0..1) == 1),
      :course => Faker::Educator.course,
      :is_examined unless(random(0..4) == 0),
      :from_university Faker::Educator.university,
      :from_city Faker::Address.city,
      :from_country Faker::Address.country,
      :from_course Faker::Educator.course,
      :photo Faker::Avatar.image(slug = nil, size = '128x128', format = 'png', set = 'students_photos', bgset = nil),
    } )
  end
end
