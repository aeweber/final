# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :destinations do
  primary_key :id
  String :title
  String :country
  String :region
  String :best_dates_to_go
  String :description, text: true
  String :location
end
DB.create_table! :comments do
  primary_key :id
  foreign_key :destination_id
  Boolean :like
  String :name
  String :email
  String :detail, text: true
end
DB.create_table! :users do
  primary_key :id
  String :name
  String :email
  String :password
end

# Insert initial (seed) data
destinations_table = DB.from(:destinations)

destinations_table.insert(title: "Northern New Mexico - Small wild trouts", 
                    country: "USA",
                    region: "New Mexico",
                    best_dates_to_go: "September - December. Anyway, you can go fly fishing year-round to this destination",
                    description: "Here",
                    location: "Northern New Mexico")

destinations_table.insert(title: "Chilean Patagonia - Baker River", 
                    country: "Chile",
                    region: "Aysen",
                    best_dates_to_go: "Fall: February - April",
                    description: "Chilean most powerful river is surounded by beautiful landscapes. Here you will find the challenging Rainbow Trout and the desired Chinook Salmon",
                    location: "Baker River")
