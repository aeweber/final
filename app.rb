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

# Temas a considerar:
# 1. Cada vez que un usuario haga log in, el homepage debe cambiar - Sacarle Jumbotron
# 2. le puedo subir fotos a las database? - https://www.ruby-forum.com/t/how-to-insert-an-image-into-database-and-how-to-display-it/179186/3
# 3. Hacer pagina "new_rsvp"
# 4. Hacer pagina "create_rsvp"


trips_table = DB.from(:trips)
comments_table = DB.from(:comments)
users_table = DB.from(:users)

get "/" do
    puts trips_table.all
    @trips = trips_table.all.to_a
    view "trips"
end

get "/trips/:id" do
    @trip = trips_table.where(id: params[:id]).to_a[0]
    @comments = comments_table.where(trip_id: @trip[:id])
    @like_count = comments_table.where(trip_id: @trip[:id], like: true).count
    @users_table = users_table
    view "trip"
end

get "/users/new" do
    view "new_user"
end