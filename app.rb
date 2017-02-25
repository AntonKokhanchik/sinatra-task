require 'sinatra'
require 'sequel'
require 'sqlite3'
require 'sinatra'
require 'slim'
require 'rack'
require 'rake'
require 'hash_dot'
require 'yaml'

# из примера беру строчку, мне она, видимо, тоже пригодится
Hash.use_dot_syntax = true

# подключение БД
DB = Sequel.connect("sqlite://#{YAML.load_file("config/database.yml").db_file_path}")

# почему бы не скопировать хелперы?..
helpers do
  # метод, собственно проверяющий авторизован ли пользователь и если нет, выдающий 401
  def protected!
    return if authorized? # то есть, тут проверяем, если да, функция заканчивается
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"' # иначе выполняем эти две строчки, которые показывают ошибку
    halt 401, "Not authorized\n"
  end

  # метод, присваивающий авторизацию через Rack с заданными значениями логин/пароль
  def authorized?
    @secrets = YAML.load_file("config/secrets.yml")
    @auth ||= Rack::Auth::Basic::Request.new(request.env) # тут.. ну какой-то запрос rack
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == %W(#{@secrets.auth.login} #{@secrets.auth.pass})
    # а если все 4 условиявыполнены (последние два - есть логин-пароль и они совпадают с секретами), то true и вернётся, иначе false
  end
end

before do
  @students = DB[:students]
  @studing_students = @students.where(is_studing: true).all
end

get '/' do
  slim  :index,                                 # задаем индексную страницу и указываем шаблонизатор
        :layout => "layouts/app".to_sym         # указываем через какой лэйаут она пройдет
end
