require_relative './model/module'

class App < Sinatra::Base

	enable :sessions
	include TodoDB

	get '/' do
		session[:logged_in] = false
		session[:invaild_reg] = false
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
			session[:invaild_reg] = true
			redirect('/register')
		end 

		if password1.empty? == true
			session[:invaild_reg] = true
			redirect('/register')
		end

		if (username.include? " ") || (username.empty? == true)
			session[:invaild_reg] = true
			redirect('/register')
		end

		username_compare = user_compare(username)
		
		if username_compare.empty? == false
			session[:invaild_reg] = true
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
		chat_id = params[:chat_id].to_i
		ids = get_user_ids_from_chatroomid(chat_id)
		user_1 = ids[0]["user_1"]
		user_2 = ids[0]["user_2"]

		username = session[:username]
		current_user = get_user_id(username)

		if ( current_user == user_1 ) || ( current_user == user_2 )
			#har detta för att fixk det att funka med detta. Funka inte med tidigare metod.
		else
			redirect('/')
		end

		@forMSG = params[:chat_id]
		session[:chat_id] = @forMSG

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
		names = []
		x = 0
		chat_id = session[:chat_id]
		chat_id = chat_id.to_i
		messages = get_messages(chat_id)

		messages.each do |id|
			test1 = id["user_id"]
			name = getUsername(test1)
			names << name
		end

		slim :messages, layout: false, locals:{messages:messages ,names:names}
	end 

	get '/adminpowers' do
		slim :admin
	end

	post '/adminpowers' do
		pw = params[:adminpw]

		if pw == "qvistisagod" #Inte särskilt bra... Får göra om senare om jag hinner 
			username = session[:username]
			updateUserValue(username)
			redirect('/home')
		else
			redirect('/adminpowers')
		end

	end

	get '/users' do
		all = getAllUsers()
		user = params['user']

		if user != nil
			@result = searchUser(user)
		end

		slim :users, locals: {all:all}
	end

	post '/users' do
		user = params["user"]

		redirect "/users?user=#{user}"
	end

	get '/user/:name' do
		user_name = params[:name]
		username = session[:username]
		@user_value = getUserValue(username)

		slim :user, locals: {user_name:user_name}
	end

	post '/startchat' do
		chat_room_name = session[:username] + " & " + params[:user_name]

		username = session[:username]
		user_id1 = get_user_id(username)

		username = params[:user_name]
		user_id2 = get_user_id(username)

		exists1 = check_for_chat1(user_id1, user_id2) # Gör detta två gånger för i databasen kan det stå på två olika sätt.
		exists2 = check_for_chat2(user_id2, user_id1)

		if ( exists1.empty? == false ) || ( exists2.empty? == false )
			redirect('/chat')
		end
		
		create_room(user_id1, user_id2, chat_room_name)

		redirect('/chat')
	end

	post '/banuser' do
		username = params[:user_name]
		user_id = get_user_id(username)
		chat_id = get_chatrooms(user_id)

		chat_id.each do |id|
			id = id["id"]
			delete_all_messages(id)
		end

		delete_from_users(username)
		delete_message(user_id) #dubble? gör det för säkerhets skull och för att det funkar atm :)
		delete_rooms(user_id)

		redirect('/home')
	end

	post '/logout' do
		session.destroy
		redirect '/'
	end

	get '/profile/:username' do
		slim :profile
	end

end