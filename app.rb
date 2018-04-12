require_relative './model/module'

require 'sinatra'
require 'sinatra-websocket'

set :server, 'thin'
set :sockets, []

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

	get '/messages' do
		messages = get_message
		slim :messages, locals:{}, layout: false
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
		p check
		check = check[1]
		p check
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
		if !request.websocket?
			slim :home
		  else
			request.websocket do |ws|
			  ws.onopen do
				ws.send("Hello World!")
				settings.sockets << ws
			  end
			  ws.onmessage do |msg|
				EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
			  end
			  ws.onclose do
				warn("websocket closed")
				settings.sockets.delete(ws)
			  end
			end
		end
	end

end           
