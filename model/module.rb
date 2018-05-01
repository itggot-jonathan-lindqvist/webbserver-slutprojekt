module TodoDB
    DB_PATH = './db/db-shitchat.sqlite'


    def db_connect
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        return db
    end

    def user_compare(username)
        db = db_connect()
        result = db.execute("SELECT * FROM users WHERE username =?",[username])
        return result
    end

    def create_user(username, crypt)
        db = db_connect()
        request = db.execute("INSERT INTO users('username','password','user_value') VALUES(?,?,?)" , [username,crypt],1)
        return request
    end

    def get_password_for_user(username)
        db = db_connect()
        info = db.execute("SELECT password FROM users WHERE username=?",[username]).first.first
        return info
    end

    def get_messages(chat_id)
        db = db_connect()
        messages = db.execute("SELECT * FROM Message WHERE chatroom_id=?",[chat_id])
        return messages
    end

    def get_user_id(username)
        db = db_connect()
        id = db.execute("SELECT id FROM Users WHERE username is ?",[username])
        return id[0]["id"]
    end

    def insert_message(chat_id, message, user_id)
        p chat_id
        p "newest"
        db = db_connect()
        db.execute("INSERT INTO Message('chatroom_id','message','user_id') VALUES(?,?,?)", [chat_id, message, user_id])
    end

    def get_chatrooms(user_id)
        db = db_connect()
        chatrooms_id = db.execute("SELECT id, room_name FROM Chatroom WHERE user_1 =? OR user_2 =?", [user_id, user_id])
        return chatrooms_id
    end

    def updateUserValue(username)
        db = db_connect()
        db.execute("UPDATE Users SET user_value = 2 WHERE username =?", [username])
    end

    def getAllUsers()
        db = db_connect()
        allUsers = db.execute("SELECT username FROM Users")
        return allUsers
    end

    def searchUser(name)
        db = db_connect()
        name = db.execute("SELECT username FROM users WHERE username LIKE ?", "%#{name}%")
        return name
    end

    def getUserValue(username)
        db = db_connect()
        value = db.execute("SELECT user_value FROM Users WHERE username =?", [username])
        return value[0]["user_value"]
    end

    def create_room(user_id1, user_id2, chat_room_name)
        db = db_connect()
        db.execute("INSERT INTO Chatroom('user_1','user_2','room_name') VALUES(?,?,?)",[user_id1, user_id2, chat_room_name])
    end

    def delete_from_users(username)
        db = db_connect()
        db.execute("DELETE FROM Users WHERE username =?", [username])
    end

    def delete_message(user_id)
        db = db_connect()
        db.execute("DELETE FROM Message WHERE user_id =?", [user_id])
    end

    def delete_rooms(user_id)
        db = db_connect()
        db.execute("DELETE FROM Chatroom WHERE user_1 =?", [user_id])
        db.execute("DELETE FROM Chatroom WHERE user_2 =?", [user_id])
    end

    def delete_all_messages(id)
        db = db_connect()
        db.execute("DELETE FROM Message WHERE chatroom_id =?", [user_id])
    end

    def getUsername(test1)
        db = db_connect()
        name = db.execute("SELECT username FROM Users WHERE id=?", [test1])
        return name
    end

end