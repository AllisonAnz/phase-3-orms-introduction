# Mapping Ruby Classes to a Database

# Map a Ruby class to a database table and an instance of a class to a table row.
# Write code that maps a Ruby class to a database table.
# Write code that inserts data regarding an instance of a class into a database table row.


# When building an ORM to connect our Ruby Program to a database 
# We equate a class with a database table and the instances that the class produces to 
# rows in the table# 
# Why map classes to tables, our end goal is to persist information regarding songs to a databse 
# In order to persist this data efficiently and in an organized manner, we need to first map or equate our 
# Ruby class to a database table

# Say we're building a mustic app that allows users to store their music and browse their songs by song 

# We would have a Song class 
# Each Song instance will have a name and an album attribute 

class Song
  attr_accessor :name, :album

  def initialize(name, album)
    @name = name
    @album = album
  end
end 

# In order to "map" this Song class to a songs database table, we need to create our database 
# Then we need to create our songs table 

# In ORM, it is conventinal to pluralize the name of the class to create the name of the table 
# There for Song class equals the "songs" table 

# Creating the Database 
# Classes are mapped to tables inside a database, not to the database as a whole 
# We may want to build other clasess that we equate with other database tables later on 

# It is the responsibility of our program as a whole to create an establish the database 
# You'll see our Ruby program set up such that they have a config directory that contains an 
# environment.rb file
# config/environment.rb
require 'sqlite3'
require_relative '../lib/song.rb'

DB = {:conn => SQLite3::Database.new("db/music.db")} 
# Above we set up a constant, DB equal to a hash that contains our connection to the database 
# in lib/song.rb, we can access DB constant and the database connection like this 
# DB[:conn]

# Now that our dtabase is set up in our program 
# Move on to our Song class and its equivalent database table 

# Creating a Table 
# Create a songs table 
# We accomplish this by writing a class method in our SOng class that creates this table 

# To "map" our class to a database table, we will create a table with the same name as 
# our class and give that table column names that match the attr_accessor of our class 

class Song

  attr_accessor :name, :album, :id

  def initialize(name, album, id=nil)
    @id = id
    @name = name
    @album = album
  end

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

end 

# Break Down 
# The id Attribute 
#   We are initializing an individual Song instance with an id attribute that has a default value of nil 
#   Songs need an id atribute only b/c they will be saved into the database and we know that 
#   each table row needs an id value which the primary key 

#   When we create a new song with the Song.new method, we do not set that song's id 
#   A song gets an id only when it gets saved into the database 
#   Therefore set the default value of the id argument to nil, so that we can create new song 
#   instances that *do not have an id value (we'll leave that up to the database to handle later on)

# The .create_table Method 
# crafts the SQL statement to create a song table and give that table column names 
# that match the attributes of an individal instance of SONG. 

# Why is .create_table method a class method?
# Well, it is not responsiblility of an individual song to create the table it will eventually be saved into 
# It is the job of the class as a whole to create the table that it is mapped to 

# TIP:
#   For strings that will take up multiple lines in you text editor use a heredoc to create a string 
#   that runs on to multiple lines 
# <<- +special word meaning "End of Doncument" 
#       + the string, on multiple lines 
#           + special word meaning "End of Document"

#----------------------------------------------------------------------------------------------------------
# Mapping Class Instances to Table Rows 
# what data are we referring to when we way we are saving data to our database
# we are not saving Ruby objects in our database 
# we are going to take the individual attributes of a given instance 
# in this case a song's name and album, 
# and save those attributes that describe an individual song to the database as one, single row. 

# For Example 
# Say we have a song 
gold_digger = Song.new("Gold Digger", "Late Registration")

gold_digger.name
# => "Gold Digger"

gold_digger.album
# => "Late Registration"  

# The song has its two attributes, name and album set equal to the above values 
# In order to save the song gold_digger into the songs table, we will use the name and album of 
# the song to create a new row in the table 
# The SQL statemenet we want to execute would looke like 
INSERT INTO songs (name, album) VALUES ("Gold Digger", "Late Registration") 

# We can abstract this process into an instance method #save 

#-----------------------------------------------------------------------------------------------------------
# Inserting Data into a table with #save Method

# Build and instance method #save,
# that saves a given instance of our Song class into the song table of our database 
    class Song

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.album)

  end
end 

# Break do 
# The #save Method 
# In order to INSERT data into our songs table, we need to craft a SQL INSERT statement 
# Ideally, it would look something like this 
INSERT INTO songs (name, album)
VALUES songs_name, songs_album

# Above we use heredoc to craft our multi-line SQL statement 
# How are we going to pass it in, or interpolate, the name an album of a given song into our heredoc?

# We use bound parameters 

# Bound Parameters 
# protect our program from getting confused by SQL injection and special characters 
# Instaed of interpolating variables into a string of SQL, we are using ? characters as placeholders 
# Then using the SQLite3-Ruby gem's execute method will take the values we pass in as an argument 
# and apply them as values of the question mark

# How it works 
# Our #save method inserts a record into our database that has the name and album values of the song instance 
# we are trying to save 
# We are not saving the RUby object itself 
# We arecreate a new row in our songs table that has the values that characterize the song instance

# Important 
# We didn't insert an ID number into the table with the above statement 
# REmember that the INTEGER PRIMARY KEY datatype will assign and auto-increment the id attribute of each record that gets saved

#--------------------------------------------------------------------------------------------------------
# Creating Instances vs Creating Table Rows 
# The moment in which we create a new Song instance with the #new method is different than the moment in which 
# we save a representation of that song to our database 

# The #new method creates a new instance of that song class, a new RUby object 
# The #save method takes the attributes that characterize a given song and aves them in a new row of the songs table in our db 

# As our program grows and changes, we may find that the need to create objects and not save them. 
# So we keep our #initialize and #save methods separate

#--------
# We can now create and save songs like this 
Song.create_table 
hello = Song.new("Hello", "25")
ninety_nine_problems = Song.new("99 Problems", "The Black Album")

hello.save
ninety_nine_problems.save

#------------------------------------------------------------------------------------------
# Giving Our Song Instance and id 
# When we INSERT the data concerning a particular Song instance into our database table 
# we create a new row in that table 
# Like below 
#   ID  Name   Albun 
#   1   Hello   25 

# Notice that the db tabl's row has a column for Name, Album and Id 
# Reacll that we created our table to have a column for the primary key, ID of a given record 
# So each record gets inserted into the db, it is given an ID number automatically 

# We want our hello instance to completely reflext the db row it is associated with 
# so that we can retrieve it from the table later on with ease 

# lets grab the ID of that newly inserted row and assign it to the value of hello's id attribute 
class Song

  attr_accessor :name, :album, :id

  def initialize(name, album, id=nil)
    @id = id
    @name = name
    @album = album
  end

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.album)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]

  end
end 

# At the end of our save method, we use a SQL query to grab the value of the ID column of the 
# last inserted row, and set that equal to the given song instances id attribute 
#--------------------------------------------------------------------------------------------

# Revisit our code that instantiated and saved some songs 
Song.create_table
hello = Song.new("Hello", "25")
ninety_nine_problems = Song.new("99 Problems", "The Black Album")

hello.save
ninety_nine_problems.save 

# Here we create the songs table 
# create two new song instances 
# Use the song.save method to persist them to the db 

# This approach still leaves a little to desired. 
# We have to first create the new song and then save it every time we want to create and save a song 
# This is repetitive 

# Since first creating an object and then saving a record representing that object is common 
# we'll write a method that does that 

# The .create Method 
# This method will wrap the code we used above to create a new Song instance and save it 
class Song 
    ...
    def self.create(name:, album:)
        song = Song.new(name, album)
        song.save
        song 
    end 
end 
# Above we use the keyword arguments to pass a name and album into our .create method 
# We use the name and album to instantiate a new song 
# Then we use the #save method to persist that song to the database
# Notice that at the end of the method, we return the song instance that we instantiated 
# The return value of .create should always be the above that we created 

#why?
# Imagin you are working with your ptogram and you create a new song 
Song.create(name: "Hello", album: "25")
# Now we would have to run a separate query on our database to grab the record that we just created
# It is much easier for our .create method to simply return the new object for us to work with 

song = Song.create(name: "Hello", album: "25")
# => #<Song:0x007f94f2c28ee8 @id=1, @name="Hello", @album="25">

song.name
# => "Hello"

song.album
# => "25" 





