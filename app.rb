require_relative './model/module'

class App < Sinatra::Base

	enable :sessions
	include TodoDB

	get '/' do
		session[:logged_in] = false
		slim :index
	end

	get '/register' do
		slim :register
	end

	post '/register' do
		username = params[:username]
		password1 = params[:pw1]
		password2 = params[:pw2]

		if password1 != password2
			session[:invaild_pass] = true
			redirect('/register')
		end 

		username_compare = user_compare(username)
		
		if username_compare.empty? == false
			session[:invaild_username] = true
			redirect('/register')
		end

		crypt = BCrypt::Password.create(password1)
		create_user(username, crypt)

		redirect('/')
        
	end

	post '/login' do
		username = params[:username]
		password = params[:password]

		session[:username] = username

		check = get_password_for_user(username)
		check = check[1]
		crypt = BCrypt::Password.new(check)

		if crypt == password
			session[:logged_in] = true
			redirect '/home'
		else
			session[:invalid_info] = true
			redirect '/'
		end
		
	end

	get '/home' do
		slim :home
	end

	get '/chat' do
		username = session[:username]

		user_id = get_user_id(username)
		chatrooms_id_and_name = get_chatrooms(user_id)

		slim :chat, locals:{chatrooms_id_and_name:chatrooms_id_and_name}
	end


	get '/room/:chat_id/:room_name' do
		@forMSG = params[:chat_id]
		session[:chat_id] = @forMSG
		p session[:chat_id]
		p "here2"

		session[:room_name] = params[:room_name]


		slim :room
	end   
	
	post '/room' do
		chat_id = session[:chat_id]
		chat_id = chat_id.to_i
		message = params[:message]
		message = message.to_s
		username = session[:username]

		user_id = get_user_id(username)
		insert_message(chat_id, message, user_id)

		redirect("/room/#{session[:chat_id]}/#{session[:room_name]}")
	end

	get '/messages' do
		chat_id = session[:chat_id]
		chat_id = chat_id.to_i
		messages = get_messages(chat_id)

		slim :messages, layout: false, locals:{messages:messages}
	end 

	get '/adminpowers' do
		slim :admin
	end

	post '/adminpowers' do
		pw = params[:adminpw]

		if pw == "qvistisagod" #maybe fix later
			username = session[:username]
			updateUserValue(username)
			redirect('/home')
		else
			redirect('/adminpowers')
		end

	end

	get '/friends' do
		all = getAllUsers()
		user = params['user']

		if user != nil
			@result = searchUser(user)
		end

		slim :friends, locals: {all:all}
	end

	post '/friends' do
		user = params["user"]

		redirect "/friends?user=#{user}"
	end

	get '/friend/:name' do
		friend_name = params[:name]
		username = session[:username]
		@user_value = getUserValue(username)

		slim :friend, locals: {friend_name:friend_name}
	end

	post '/startchat' do
		chat_room_name = session[:username] + " & " + params[:friend_name]

		username = session[:username]
		user_id1 = get_user_id(username)

		username = params[:friend_name]
		user_id2 = get_user_id(username)
		
		create_room(user_id1, user_id2, chat_room_name)

		redirect('/chat')
	end

	post '/banuser' do
		username = params[:friend_name]
		user_id = get_user_id(username)
		chat_id = get_chatrooms(user_id)

		chat_id.each do |id|
			id = id["id"]
			delete_all_messages(id)
		end

		delete_from_users(username)
		delete_message(user_id) #dubble?
		delete_rooms(user_id)

		redirect('/home')
	end

end