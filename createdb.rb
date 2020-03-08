# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :resorts do
  primary_key :id
  String :resort_name
  String :description, text: true
  String :location
end
DB.create_table! :reviews do
  primary_key :id
  foreign_key :resort_id
  foreign_key :user_id
  String :comments, text: true
  String :rating
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
resorts_table = DB.from(:resorts)

resorts_table.insert(resort_name: "Mt. Snow", 
                    description: "The East Coast's premiere ski destination!",
                    location: "Dover, VT")

resorts_table.insert(resort_name: "Deer valley", 
                    description: "Exclusive skiing for an exclusive clientele.",
                    location: "Park City, UT")
