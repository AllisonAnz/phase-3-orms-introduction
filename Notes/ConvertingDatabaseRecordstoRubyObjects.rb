# Converting Database Records to Ruby Objects

# Learning Goals
# Build methods that read from a database table
# Build a Song.all class method that returns all songs from the database
# Build a Song.find_by_name class method that accepts one argument, a name searches the database for a song with that name and returns the matching song entry if one is found
# Convert what the database gives you into a Ruby object

# Cover the basics of reading from a db table that is mapped to a Ruby Object 

# Ruby userstands objects. The database understands raw data 

# Example
# Use a song domain as an example 
# A Song class that is responsible for making songs 
# Every song will come with two attributes, a title and a length 

# Imagin we already have a db with 1 million songs 
# We need to build three methods to access all of those songs and convert them to Ruby Objects 

# .new_from_db 
# First we need to conver what the db gives us into a Ruby Object 
# We use this method to create all the Ruby objects in our next two methods 

# Know that the db, SQLite in our case, will return an array of data for each row 
# For example a row for MJ's "Thriller" that has a db id of 1 would look like 

def self.new_from_db(row)
  new_song = self.new  # self.new is the same as running Song.new
  new_song.id = row[0]
  new_song.name =  row[1]
  new_song.length = row[2]
  new_song  # return the newly created instance
end 

# Notice since we're retrieving data from our db, we are using new 
# We don't need to create records 
# With this method we're reading data from SQLite and temporarily 
# represnting that data in Ruby 

# Song.all 
# Write a method to retrieve the data 
# To return all the songs in the db we need to execute the following SQL query: SELECT * FROM songs 

# Let's store that in a variable called sql using heredoc (<<-) since our string will go onto multipl lines 
#   sql = <<-SQL
#     SELECT *
#     FROM songs 
#   SQL

# Next we'll make a call to our db using DB[:conn]
# this DB hash is located in the config/environment.rb file 
# DB = {:conn => SQLite3::Database.new("db/songs.db")}
# Notice that the value of the hash is actually a new instance of the SQLite::Database class
# This is how we will connect to our database 

# Our database instance respons to a method called exectue 
# execute accepts raw SQL as a string 
# Pass in that SQL we stored above 

class Song
  def self.all
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL

    DB[:conn].execute(sql)
  end
end 

# This returns an array of rows from the database that matches our query 

# Now we iterate over each row and use the self.new_from_db method to create a new 
# Ruby object for each row

class Song
  def self.all
    sql = <<-SQL
      SELECT *
      FROM songs
    SQL

    DB[:conn].execute(sql).map do |row|
      self.new_from_db(row)
    end
  end
end 

#-----------------------------------------------------------------------------------
# Song.find_by_name 
# similar to Song.all with the exception being that we have to include a name in our SQL statement 
# To do this, we use a question mark where we want the name parameter to be passed in, and include name as 
# the second argument to the execute method 

class Song
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM songs
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
  end
end 

# .first method chained to the end of the DB[:conn].execute(sql, name).map block 
# The return value of the .map method is an array and we're simply grabbing the .first element from the returned array