# Updating Records 

#Write a method that will update an existing database record once changes have been made to that record's equivalent Ruby object
#Identify whether a Ruby object has already been persisted to the database
#Build a method that can either find and update or create a database record

# What do we need to do to update a record 
# First we need to find the appropriate record 
# Then make some changes 
# and then save it again 

# In Ruby ORM, where attributes of given Ruby objets are stored as an individual row in a db table 
# we need to retrieve these attributes, reconstitue them into a Ruby object 
# make changes to that object using Ruby methods, and then 
# save those (newly updated) attributes back into the db 

# Updating a Record in Ruby ORM 
# In this example we are working with a music management app 
# allows users to store their songs 
# Has a Song class that maps to a songs database table 
# Our Song class has all the methods it needs to create the songs table, insert records into 
# that table and retrieve records from that table 

# The Song CLass 
# For this example, we'll assume that our database connection is stored in the DB[:conn] constant.

class Song

attr_accessor :name, :album
attr_reader :id

  def initialize(id=nil, name, album)
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

  def save
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.album)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
  end

  def self.create(name:, album:)
    song = Song.new(name, album)
    song.save
    song
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM songs WHERE name = ?"
    result = DB[:conn].execute(sql, name)[0]
    Song.new(result[0], result[1], result[2])
  end
end 

# We can create new Song instance, save them to the db and retrieve them 
ninety_nine_problems = Song.create(name: "99 Problems", album: "The Blueprint")

Song.find_by_name("99 Problems")
# => #<Song:0x007f94f2c28ee8 @id=1, @name="99 Problems", @album="The Blueprint">

#----------------------------------------------------------------------------------
# Updating Songs 
# In order to update a record, we must first find it 
# update The Blueprint album to The Black Album 

ninety_nine_problems.album = "The Black Album"
ninety_nine_problems.album
# => "The Black Album" 

# Now we need an UPDATE SQL statement 
UPDATE songs
SET album="The Black Album"
WHERE name="99 Problems"; 

# Put it all together 
sql = "UPDATE songs SET album = ? WHERE name = ?"
DB[:conn].execute(sql, ninety_nine_problems.album, ninety_nine_problems.name) 
# Above we updated the album of a given song 

# We can abstract this out into an #update Method 
# and use IDs to identifying Objects and Records Using ID
#-----------------------------------------------------------------------------

# Identifying Objects and Records Using ID
# We need a way to select a Ruby object's analogous table row using a fixed and unique attribute 
# Song records in the db table have a unique id 
# and our Song instances have an id attribute 
# Recall that we have been setting the id attribute of individual songs directly after 
# the data regarding that song gets inserted into the db table, right at the end of our #save method 

# The unique id number of a Song instance should come from the database 
# WHen a song record gets inserted into the database, the row gets assigned a unique ID number 
# We need to grab that ID number from the db record and assign it to the songs instance's id attribute 

# Break it down 
# Create a new instance of the Song class 
#   That instance has a name and album attr. But its id attribute is nil 
# The name and album of this song instance are used to create a new db record 
#   a new row in the songs table 
#   The record has an ID of 1 (this appears to be the first song saved in the db)
# The ID of the newly created database record is then taken and assigned to the id attribute 
# of the orginal songs object

# This is the pattern, every instance of the Song class that is ever saved into the db will be assigned 
# a unique id attribute that we can use to differentiate it from the other SOng objects we created 

#--------------------------------------------------------------------------------------------
# Assigning Unique IDs on #save 
# The Song instance should get assigned a unique id 
# Right after we INSERT it into the db 
# At the point, its equvalent db record will have a unique ID in the ID column 
# We want to grab that ID and use it to assign the Song objects id value 

# When do we INSERT a new record into our db?
# In the #save method 
def save
  sql = <<-SQL
    INSERT INTO songs (name, album)
    VALUES (?, ?)
  SQL
  DB[:conn].execute(sql, self.name, self.album)
  @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
end 

# See what happens when we create a new Song 
hello = Song.create(name: "Hello", album: "25")
hello.name # => "Hello"
hello.album # => "25"
hello.id # => 1 

# Using id to Update Records 
#update method identifies the correct record to update base on the unique ID that both the 
# song Ruby object and the songs table row share 
class Song
  ...

  def update
    sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.album, self.id)
  end
end 

# Refactoring our #save Method to avoid Duplication 
# This method will always INSERT a new row into the db table 
# What happens if we accedentally call #save on an object that has already been persisted and 
# has an analogous database row 

# We know an object persisted, If it has an id that is not nil 
# Object's id attr gets set only once it has been INSERTED into the db 
def save
  if self.id
    self.update
  else
    sql = <<-SQL
      INSERT INTO songs (name, album)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.album)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM songs")[0][0]
  end
end 