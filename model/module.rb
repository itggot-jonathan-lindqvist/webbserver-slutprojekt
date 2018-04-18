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
        db =db_connect()
        messages = db.execute("SELECT * FROM Message WHERE chatroom_id=?",[chat_id])
        return messages
    end

    # def db_connect
    #     db = SQLite3::Database.new(DB_PATH)
    #     db.results_as_hash = true
    #     return db
    # end

    # def get_user username
    #     db = db_connect()
    #     result = db.execute("SELECT * FROM users WHERE username=?", [username])
    #     return result.first
    # end

    # def create_user username, password
    #     db = db_connect()
    #     password_digest = BCrypt::Password.create(password)
    #     db.execute("INSERT INTO users(username, password_digest) VALUES (?,?)", [username, password_digest])
    # end

    # def list_notes user_id
    #     db = db_connect()
    #     return db.execute("SELECT * FROM notes WHERE user_id=?", [user_id])
    # end

    # def get_note note_id
    #     db = db_connect()
    #     result = db.execute("SELECT * FROM notes WHERE id=?", [note_id])
    #     return result.first
    # end

    # def update_note user_id, note_id, new_content
    #     db = db_connect()
    #     result = db.execute("SELECT user_id FROM notes WHERE id=?",[note_id])
    #     if result.first["user_id"] == user_id
    #         db.execute("UPDATE notes SET content=? WHERE id=?",[new_content, note_id])
    #     end
    # end

    # def create_note user_id, content
    #     db = db_connect()
    #     db.execute("INSERT INTO notes(user_id, content) VALUES (?,?)", [user_id, content])
    # end

    # def delete_note user_id, note_id
    #     db = db_connect()
    #     note = get_note(note_id)
    #     # byebug
    #     if user_id == note["user_id"]
    #         db.execute("DELETE FROM notes WHERE id=?",[note_id])
    #     end
    # end
end