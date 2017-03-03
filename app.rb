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
  @cities = DB[:cities]
  @countries = DB[:countries]
  @universities = DB[:universities]
end

get '/' do
  @show_list = @studing_students

  if params[:photo]!=nil
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
  end
  @show_list = @show_list.all
  slim  :index,
        :layout => "layouts/app".to_sym,
        :locals => {:gender => params[:gender], :photo => params[:photo], :course => params[:course], :from_country => params[:country]}
end

get '/admin' do
  slim  :admin,
        :layout => "layouts/admin_l".to_sym
end

get '/admin/cities' do
  slim  :cities,
        :layout => "layouts/admin_l".to_sym
end

get '/admin/universities' do
  slim  :universities,
        :layout => "layouts/admin_l".to_sym
end

get '/admin/countries' do
  slim  :countries,
        :layout => "layouts/admin_l".to_sym
end

get '/admin/edit_student/:id' do
  @student = @studing_students.where(id: params[:id]).first
  slim  :edit_student,
        :layout => "layouts/admin_l".to_sym
end

post '/admin/edit_student/:id' do
  @students.where(id: params[:id]).update( {
    :student_surname => params[:student_surname],
    :student_name => params[:student_name],
    :student_middlename => params[:student_middlename],
    :is_male => if params[:is_male]=='true' then true else false end,
    :course => params[:course],
    :is_examined => if params[:is_examined]=='true' then true else false end,
    :from_university => params[:from_university],
    :from_city => params[:from_city],
    :from_country => params[:from_country],
    :from_course => params[:from_course]
  } )
  redirect "/admin"
end

get '/admin/add_student' do
  slim  :add_student,
        :layout => "layouts/admin_l".to_sym
end

post '/admin/add_student' do
  @students.insert( {
    :student_surname => params[:student_surname],
    :student_name => params[:student_name],
    :student_middlename => params[:student_middlename],
    :is_male => params[:is_male],
    :course => params[:course],
    :is_examined => params[:is_examined],
    :from_university => params[:from_university],
    :from_city => params[:from_city],
    :from_country => params[:from_country],
    :from_course => params[:from_course]
  } )
  redirect "/admin"
end

post '/admin/dismiss' do
  dismissing = @studing_students.where(id: params[:dismiss]).update(is_studing: false)
  redirect "/admin"
end

post '/admin/delete/university' do
  @universities.where(id: params[:delete]).update(is_partner: false)
  redirect "/admin/universities"
end

post '/admin/delete/city' do
  @cities.where(id: params[:delete]).update(is_partner: false)
  redirect "/admin/cities"
end

post '/admin/delete/country' do
  @countries.where(id: params[:delete]).update(is_partner: false)
  redirect "/admin/countries"
end
