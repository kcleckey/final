# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"     
require "geocoder"                                                                 #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

resorts_table = DB.from(:resorts)
reviews_table = DB.from(:reviews)
users_table = DB.from(:users)


before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

get "/" do
    puts resorts_table.all
    @resorts = resorts_table.all.to_a
    view "resorts"
end

get "/resorts/:id" do
    @resort = resorts_table.where(id: params[:id]).to_a[0]
    @reviews = reviews_table.where(resort_id: @resort[:id])
    @users_table = users_table
    results = Geocoder.search(@resort[:location])
    @lat_long = results.first.coordinates
    @lat = @lat_long[0]
    @long = @lat_long[1]
    view "resort"
end

get "/resorts/:id/reviews/new" do
    @resort = resorts_table.where(id: params[:id]).to_a[0]
    view "new_review"
end

get "/resorts/:id/reviews/create" do
    puts params
    @resort = resorts_table.where(id: params["id"]).to_a[0]
    reviews_table.insert(resort_id: params["id"],
                       user_id: session["user_id"],
                       rating: params["rating"],
                       comments: params["comments"])
    view "create_review"
end

get "/users/new" do
    view "new_user"
end

post "/users/create" do
    puts params
    hashed_password = BCrypt::Password.create(params["password"])
    users_table.insert(name: params["name"], email: params["email"], password: hashed_password)
    view "create_user"
end

get "/logins/new" do
    view "new_login"
end

post "/logins/create" do
    user = users_table.where(email: params["email"]).to_a[0]
    puts BCrypt::Password::new(user[:password])
    if user && BCrypt::Password::new(user[:password]) == params["password"]
        session["user_id"] = user[:id]
        @current_user = user
        view "create_login"
    else
        view "create_login_failed"
    end
end

get "/logout" do
    session["user_id"] = nil
    @current_user = nil
    view "logout"
end
