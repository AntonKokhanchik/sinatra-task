# опять всё тупо скатаю, ибо вроде тут всё так как надо

# Создаем отдельный namespace для работы с БД
namespace :db do

  # подключаем необходимые для работы с БД гемы
  require 'sequel'
  require 'sqlite3'

  # подключаем поддержку YAML (rake это не Sinatra, тут по-умолчанипю ее нет)
  require 'yaml'

  # также подключаем гем для удобства настроек
  require 'hash_dot'

  # подключаем расширение поддержки механизма миграций
  Sequel.extension :migration

  # грузим настройки БД из файла
  @db_settings = YAML.load_file("config/database.yml").to_dot
  @db_file = @db_settings.db_file_path

  # подключаем его глобально в качестве БД
  DB = Sequel.connect("sqlite://#{@db_file}")

  desc "Создаем новую БД SQLite"
  task :create do

    # создаем чистый файл для нашей БД
    touch @db_file

    puts "Создана новая локальная БД: #{@db_file}"
  end

  desc "Показывает текущую версию миграции БД"
  task :version do

    # проверяем есть ли в БД таблица схемы с указанной версией
    version = if DB.tables.include?(:schema_info)
      DB[:schema_info].first[:version]
    end || 0

    puts "Версия миграции БД: #{version}"
  end

  desc "Прогоняем все доступные миграции нашей БД SQLite"
  task :migrate do

    # запускаем мигратор
    Sequel::Migrator.run(DB, "db/migrations")

    # проверяем версию
    Rake::Task['db:version'].execute

    puts "Все доступные миграции произведены"
  end

  desc "Откатываемся на указанную версию БД либо полностью если версия не указана"
  task :rollback do

    # сначала проверяем текущую версию
    Rake::Task['db:version'].execute

    # запрашиваем целевую версию
    puts "Укажите целевую версию миграции (целое число)"

    # важно что тут мы явно указываем откуда получаем ввод, а именно STDIN, иначе
    # rake выдаст ошибку ибо по-умолчанию он работает в не-интерактивном режиме;
    # таким образом этот таск будет выполняться только локально!
    # заодно мы указываем 0 версию на случай если никакая не будет указана
    target = STDIN.gets.chomp.to_i || 0

    # запускаем мигратор с указанием целевой версии
    Sequel::Migrator.run(DB, "db/migrations", :target => target)

    # проверяем версию
    Rake::Task['db:version'].execute

    puts "Откат миграций произведен"
  end

  desc "Заполняем БД случайными данными для проверки"
  task :seed do

    # сначала запускаем миграции, убеждаемся что БД актуальная
    Rake::Task['db:migrate'].execute

    # собственно запускаем seed
    require_relative '../db/seeds.rb'

    puts "БД заполнена случайными данными для проверки"
  end

  desc "Грохаем нашу БД SQLite"
  task :drop do
    rm @db_file
    puts "Удалена БД: #{@db_file}"
  end

end
