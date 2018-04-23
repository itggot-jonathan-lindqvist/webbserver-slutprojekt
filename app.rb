require_relative './model/module'

#require 'sinatra'
#require 'sinatra-websocket'

#set :server, 'thin'
#set :sockets, []

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

#	get '/messages' do
#		messages = get_message
#		slim :messages, locals:{}, layout: false
#	end

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
		#if !request.websocket?
		#	slim :home
		 # else
			#request.websocket do |ws|
			 # ws.onopen do
				#ws.send("Hello World!")
				#settings.sockets << ws
			  #end
			  #ws.onmessage do |msg|
				#EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
			  #end
			  #ws.onclose do
				#warn("websocket closed")
				#settings.sockets.delete(ws)
			  #end
			#end
		#end
		slim :home
	end

	get '/chat' do
		username = session[:username]
		user_id = get_user_id(username)
		chatrooms_id = get_chatrooms(user_id)
		slim :chat, locals:{chatrooms_id:chatrooms_id}
	end


	get '/room/:chat_id' do
		slim :room
	end

	get '/messages' do
		username = session[:username]
		user_id = get_user_id(username)
		p user_id
		chatrooms_id = get_chatrooms(user_id)
		p chatrooms_id
		chat_id = chatrooms
		messages = get_messages(chat_id)
		slim :messages, locals:{messages:messages}, layout: false
	end    
	
	post '/room/:chat_id' do
		chat_id = params[:chat_id]
		message = params[:message]
		username = session[:username]
		user_id = get_user_id(username)
		#p user_id
		insert_message(chat_id, message, user_id)
	end

	get '/adminpowers' do
		slim :admin
	end

	post '/adminpowers' do
		pw = params[:adminpw]

		if pw == "qvistisagod"
			username = session[:username]
			updateUserValue(username)
			redirect('/home')
		else
			redirect('/adminpowers')
		end
	end
end