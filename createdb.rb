# Set up for the application and database. DO NOT CHANGE. #############################
require "sequel"                                                                      #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB = Sequel.connect(connection_string)                                                #
#######################################################################################

# Database schema - this should reflect your domain model
DB.create_table! :trips do
  primary_key :id
  String :title
  String :description, text: true
  String :date
  String :location
end
DB.create_table! :rsvps do
  primary_key :id
  foreign_key :event_id
  Boolean :going
  String :name
  String :email
  String :comments, text: true
end

# Insert initial (seed) data
trips_table = DB.from(:trips)

trips_table.insert(title: "New Mexico Trip", 
                    description: "XXXX",
                    date: "June 21",
                    location: "New Mexico")

trips_table.insert(title: "Fly fhishing in Chilean Patagonia - Baker River", 
                    description: "YYYY",
                    date: "December 6",
                    location: "Rio Baker, Aysen, Chile")
