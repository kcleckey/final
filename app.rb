# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"                                                                     #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "twilio-ruby"                                                                 #
require "bcrypt"                                                                      #
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

get "/" do
    puts resorts_table.all
    @resorts = resorts_table.all.to_a
    view "resorts"
end

get "/resorts/:id" do
    @resort = resorts_table.where(id: params[:id]).to_a[0]
    @review = reviews_table.where(resort_id: @resort[:id])
    #@users_table = users_table
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
#                       user_id: session["user_id"],
                       comments: params["comments"])
    view "create_review"
end