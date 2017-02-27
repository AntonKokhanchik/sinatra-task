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
  p params
  @students = DB[:students]
  @studing_students = @students.where(is_studing: true).order(:student_surname)
  @show_list = @studing_students.all
end

# TODO: реализовать неизменность формы при фильтрации
get '/' do
  @show_list = @studing_students
  if params[:photo] == "yes"
    @show_list = @show_list.exclude(:photo => nil)
  elsif params[:photo] == "no"
      @show_list = @show_list.where(:photo => nil)
  end

  if params[:gender] == "male"
    @show_list = @show_list.where(:is_male => true)
  elsif params[:gender] == "female"
    @show_list = @show_list.where(:is_male => false)
  end

  if params[:course] != ""
    @show_list = @show_list.where(:course => params[:course])
  end

  if params[:country] != ""
    @show_list = @show_list.where(:from_country => params[:country])
  end

  @show_list = @show_list.all
  slim  :index,
        :layout => "layouts/app".to_sym
end

get '/admin' do
  slim  :admin,                                 # задаем индексную страницу и указываем шаблонизатор
        :layout => "layouts/admin_l".to_sym
end
