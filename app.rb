class App < Sinatra::Base

	enable :sessions
	get '/' do
		slim :index
	end

	get '/register' do
		slim :register
	end

	post '/register' do
		db = SQLite3::Database.new('./db/db-shitchat.sqlite')
		username = params[:username]
		password1 = params[:pw1]
		password2 = params[:pw2]

		if password1 != password2
			session[:invaild_pass] = true
			redirect('/register')
		end 

		username_compare = db.execute("SELECT * FROM users WHERE username =?",[username])
		
		if username_compare.empty? == false
			session[:invaild_username] = true
			redirect('/register')
		end
		crypt = BCrypt::Password.create(password1)
		db.execute("INSERT INTO users('username','password','user_value') VALUES(?,?,?)" , [username,crypt],1)
		redirect('/')
        
	end

	post '/login' do
		username = params[:username]
		password = params[:password]

		db = SQLite3::Database.new('./db/db-shitchat.sqlite')

		session[:username] = username

		check = db.execute("SELECT password FROM users WHERE username=?",[username]).first.first
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

end           
