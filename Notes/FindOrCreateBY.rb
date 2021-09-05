# Find or Create By 
# Avoid creating duplicate records in a database that is mapped to a Ruby program
# Build a #find_or_create_by method

class Song

attr_accessor :name, :album
attr_reader :id

  def initialize(id=nil, name, album)
    @id = id
    @name = name
    @album = album
  end

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

  def self.create(name:, album:)
    song = Song.new(name, album)
    song.save
    song
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM songs WHERE id = ?"
    result = DB[:conn].execute(sql, id)[0]
    Song.new(result[0], result[1], result[2])
  end

  def update
    sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.album, self.id)
  end
end 

# find_or_create_by method 
def self.find_or_create_by(name:, album:)
    song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, album)
    if !song.empty?
      song_data = song[0]
      song = Song.new(song_data[0], song_data[1], song_data[2])
    else
      song = self.create(name: name, album: album)
    end
    song
end

# Break it down 
#First we query the db: does a record exist that has this name?
song = DB[:conn].execute("SELECT * FROM songs WHERE name = ? AND album = ?", name, album) 

# If such a record exists, the song variable will now point to an array 
[[1, "Hello", "25"]] 

# If this is the case, then the statement 
!song.empty? 
# will return true 
# We will use the returned values to make a new "Hello" object that RUby can play around with 
# but we will not save it to the db 

# The re-instantiation of an existing Song object is accomplished with these lines 
song_data = song[0]
song = Song.new(song_data[0], song_data[1], song_data[2]) 

# We grab the song_data from the song array of arrays setting song_data equal to 
[1, "Hello", "25"] 
# Then we use this array to create a new Song instanace with the given id, name and album 

# However if no record exists that matches the name and album 
# We instead create an save a new Song instance with the #create method

# At the end of the method we return the song object whose db entry we wither found or created

# Code in Action 
# Now we can use our SOng class without worrying about creating duplicates 
Song.find_or_create_by(name: "Hello", album: "25")
Song.find_or_create_by(name: "Hello", album: "25")

DB[:conn].execute("SELECT * FROM songs WHERE name = Hello, album = 25")
# => [[1, "Hello", "25"]] 