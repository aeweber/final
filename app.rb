# Set up for the application and database. DO NOT CHANGE. #############################
require "sinatra"
require "sinatra/cookies"                                                             #
require "sinatra/reloader" if development?                                            #
require "sequel"                                                                      #
require "logger"                                                                      #
require "bcrypt"                                                                      #
require "twilio-ruby"                                                                 #
connection_string = ENV['DATABASE_URL'] || "sqlite://#{Dir.pwd}/development.sqlite3"  #
DB ||= Sequel.connect(connection_string)                                              #
DB.loggers << Logger.new($stdout) unless DB.loggers.size > 0                          #
def view(template); erb template.to_sym; end                                          #
use Rack::Session::Cookie, key: 'rack.session', path: '/', secret: 'secret'           #
before { puts; puts "--------------- NEW REQUEST ---------------"; puts }             #
after { puts; }                                                                       #
#######################################################################################

# Temas a considerar:
# 2. Cada vez que un usuario haga log in, el homepage debe cambiar - Sacarle Jumbotron # Cambiar redirect "/" en /logins/create 
# 3. le puedo subir fotos a las database? - https://www.ruby-forum.com/t/how-to-insert-an-image-into-database-and-how-to-display-it/179186/3
# 4. Pagina "/destinations/id" poner numero de likes y dislikes
# 5. Se le podria poner otro formato a "country" y " region" en hoja "destination"
# 7. Crear pagina (a) create_login, (b) create_comment, (d) destroy_comment, (e) logout, (f) update_comment
# I got a fever - https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSpbdW8OHsXALx9oPDfYQVV3z_5deuXa9ngyIeSpRFnlCScmbdO


destinations_table = DB.from(:destinations)
comments_table = DB.from(:comments)
users_table = DB.from(:users)

before do
    @current_user = users_table.where(id: session["user_id"]).to_a[0]
end

# homepage and list of destinations
get "/" do
    puts "params: #{params}"

    @destinations = destinations_table.all.to_a
    pp @destinations

    view "destinations"
end

# destination details 
get "/destinations/:id" do

    puts "params: #{params}"

    @users_table = users_table
    @destination = destinations_table.where(id: params[:id]).to_a[0]
    pp @destination

    @comments = comments_table.where(destination_id: @destination[:id]).to_a
    @like_count = comments_table.where(destination_id: @destination[:id], like: true).count

    view "destination"
end

# display the comment form
get "/destinations/:id/comments/new" do
    puts "params: #{params}"

    @destination = destinations_table.where(id: params[:id]).to_a[0]
    view "new_comment"
end

# receive the submitted comment form
post "/destinations/:id/comments/create" do
    puts "params: #{params}"

    # first find the destination that commenting for
    @destination = destinations_table.where(id: params[:id]).to_a[0]
    # insert a row in the comments table with the comment form data
    comments_table.insert(
        destination_id: @destination[:id],
        user_id: session["user_id"],
        details: params["details"],
        like: params["like"]
    )

    redirect "/destinations/#{@destination[:id]}"
end

# display the comment form
get "/comments/:id/edit" do
    puts "params: #{params}"

    @comment = comments_table.where(id: params["id"]).to_a[0]
    @destination = destinations_table.where(id: @comment[:destination_id]).to_a[0]
    view "edit_comment"
end

# receive the submitted (updated) comment form 
post "/comments/:id/update" do
    puts "params: #{params}"

    # find the comment to update
    @comment = comments_table.where(id: params["id"]).to_a[0]
    # find the comment's destination
    @destination = destinations_table.where(id: @comment[:destination_id]).to_a[0]

    if @current_user && @current_user[:id] == @comment[:id]
        comments_table.where(id: params["id"]).update(
            like: params["like"],
            details: params["details"]
        )

        redirect "/destinations/#{@destination[:id]}"
    else
        view "error"
    end
end

# delete the comment 
get "/comments/:id/destroy" do
    puts "params: #{params}"

    comment = comments_table.where(id: params["id"]).to_a[0]
    @destination = destinations_table.where(id: comment[:destination_id]).to_a[0]

    comments_table.where(id: params["id"]).delete

    redirect "/destinations/#{@destination[:id]}"
end

# display the signup form 
get "/users/new" do
    view "new_user"
end

# receive the submitted signup form
post "/users/create" do
    puts "params: #{params}"

    # if there's already a user with this email, skip!
    existing_user = users_table.where(email: params["email"]).to_a[0]
    if existing_user
        view "error"
    else
        users_table.insert(
            name: params["name"],
            email: params["email"],
            password: BCrypt::Password.create(params["password"])
        )
        redirect "/users/create"
    end
end

# display the login form
get "/users/create" do
    view "create_user"
end

# display the login form
get "/logins/new" do
    view "new_login"
end

# receive the submitted login form
post "/logins/create" do
    puts "params: #{params}"

    # step 1: user with the params["email"] ?
    @user = users_table.where(email: params["email"]).to_a[0]

    if @user
        # step 2: if @user, does the encrypted password match?
        if BCrypt::Password.new(@user[:password]) == params["password"]
            # set encrypted cookie for logged in user
            session["user_id"] = @user[:id]
            redirect "/"
        else
            view "create_login_failed"
        end
    else
        view "create_login_failed"
    end
end

# logout user
get "/logout" do
    # remove encrypted cookie for logged out user
    session["user_id"] = nil
    redirect "/logins/new"
end
