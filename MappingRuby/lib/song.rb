require 'sqlite3'
class Song

  attr_accessor :name, :album, :id

  # initialize id to nil, so that we can create a new song instance (Song.new method) that don't have an id value
    def initialize(name, album, id=nil)
      @id = id
      @name = name
      @album = album
    end

# crafts a SQL statement to create a songs table and give that table column names 
# that match the attributes of an individual instance of Song
     def self.create_table
    sql =  <<-SQL 
      CREATE TABLE IF NOT EXISTS songs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        album TEXT
        )
        SQL
    DB[:conn].execute(sql) 
  end
  
# An instance method that saves a given instance of our Song class into the songs table of our database
# Bound Parameters protect our program from getting confused by SQL injection and special characters 
# using ? as a placeholder the #execute method will take the values we pass in as arguments and apply them as the values of the '?'s.
# The #save method inserts a record into our db that has the name and album values of the song instance 
# We are creating a new row in our songs table that has the values that characterize the song instance   
    def save
    sql = <<-SQL
      INSERT INTO songs (name, album) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.album)
    
    # an SQL query that grabs the value of the ID column of the last inserted row, and sets it equal to the given song instances id attribute
     @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
  end

  # We use keyarguments to pass a name and album to instantiate a new song 
  # Then we use the #save method to persist that song to the db 
  # then return the song instance that we instantiated
   def self.create(name:, album:)
    song = Song.new(name, album)
    song.save
    song
  end

end 

# Notes on self.create_table 
# For Example 
# Say we have a song 
#   gold_digger = Song.new("Gold Digger", "Late Registration")
#   gold_digger.name # => "Gold Digger"
#   gold_digger.album # => "Late Registration"  
# The song has its two attributes, name and album set equal to the above values 
# In order to save the song gold_digger into the songs table, we will use the name and album of 
# the song to create a new row in the table, The SQL statemenet we want to execute would looke like 
#   INSERT INTO songs (name, album) VALUES ("Gold Digger", "Late Registration") 

# We can now create and save songs like this 
Song.create_table 
hello = Song.new("Hello", "25")
ninety_nine_problems = Song.new("99 Problems", "The Black Album")

hello.save
ninety_nine_problems.save

# ***Using .create method, we can cut out the above repetiveness of creating a song instance 
song = Song.create(name: "Hello", album: "25")
# => #<Song:0x007f94f2c28ee8 @id=1, @name="Hello", @album="25">

song.name
# => "Hello"

song.album
# => "25" 





































































































































