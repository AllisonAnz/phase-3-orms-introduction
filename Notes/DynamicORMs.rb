# Dynamic ORMs 

# Explain why a dynamic ORM is useful to us as developers
# Build a basic dynamic ORM
# Build a dynamic ORM that can be used by any given Ruby class

# We use the ORM design patter in which a Ruby class is mapped to a db table 
# and instances of that class are represented as rows in the table 

# We can implement this mapping by using a class to create a database table 

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
end 

# Above is one way to map our program to our DB, but has some limitation 
#create_table method is dependent on knowing what to name our table and columns 
# So every class in our program would require us to re-write this #create_table method

# We can abstract this into a re-useable method
# With dynamic ORM, we can abstract all of our conventional ORM methods into a flexiable, abstract and shareable methods 

# Dynamic ORM allow us to map an existing db table to a class and write methods that can 
# use nothing more than information regarding a sepecific database table to:
#   Create attr_accessors for Ruby class 
#   Create shareable methods for inserting, updating, selecting and deleting data from the dtabase 
# This pattern, first creating the db table and having your program do all the work of writing your ORM methods is exactly how we will develop wep aoolications using Sinatra and Rails 

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Creating Our ORM 

# STEP 1: Setting Up the Database 
# To create a dynamic ORM, start by creating a database and songs table 
# In config/environment.rb 
require 'sqlite3'
# Creating a database
DB = {:conn => SQLite3::Database.new("db/songs.db")}
# Drop songs to avoid an error
DB[:conn].execute("DROP TABLE IF EXISTS songs")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL
# Creating the songs table
DB[:conn].execute(sql)
# This method says: when a SELECT statement is executed, don't return an database row as an array 
# return it as a hash with the column names as keys
DB[:conn].results_as_hash = true 

# So instead of DB[:conn].execute("SELECT * FROM songs LIMIT 1" returning something like this 
[[1, "Hello", "25"]] 
# It will return something like 
{"id"=>1, "name"=>"Hello", "album"=>"25", 0 => 1, 1 => "Hello", 2 => "25"} 

# This will be helpful to use as we use information, requested from our databse table to build attributes 
# and methods on our SOng class 

#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 2: Building attr_accessors from column names 
# Use the column names of the songs table to dynamically create the attr_accessor of our Song class 
# We need to first collect the column names from our songs table 
# In order to do this tell our Song class what table to query 

#table_name Method 
class Song
  def self.table_name
    self.to_s.downcase.pluralize
  end
end 
# Above takes the name of the class referenced by self keyword, turns it into a string, downcases and then "pluralizes" it (makes it plural)
# active_support/inflector code library, required at the top of lib/song.rb.

#column_name method 
# How do we query a table for names of its columns 
# we use this query 
PRAGMA table_info(<table name>) 

#--PRAGMA 
#  -- query a table for the names of its column 
#  PRAGMA table_info(<table name>) 
#  -- thanks to #results_as_hash method will return 
#  -- an array of hashes describing the table itself 
#  -- each hash will contain information about one column 
#  /* [{"cid"=>0, "name"=>"id", "type"=>"INTEGER", "notnull"=>0, "dflt_value"=>nil, ...
#      {"cid"=>1, "name"=>"name", "type"=>"TEXT", "notnull"=>0, "dflt_value"=>nil, "pk"=>0, 0=>1, 1=>"name", 2=>"TEXT", 3=>0, 4=>nil, 5=>0}, ....*/

# The only thing we need to grab of this hash is the name of each column 
# Each hash has a "name" key that points to a value of the column name 

# We know how to get information abotu each column from our table 
# Write our #column_names method 
def self.column_names
  DB[:conn].results_as_hash = true

  sql = "PRAGMA table_info('#{table_name}')"

  table_info = DB[:conn].execute(sql)
  column_names = []

  table_info.each do |column|
    column_names << column["name"]
  end

  column_names.compact
end 
# Above using the pragma keyword and #table_name method(to access the name of the table we are querying)
# iterate over the resulting array of hashes to collect just the name of each column 
#compact gets rid of any nil values that may end up in our colection

# The return value of Calling Song.column_names will be 
["id", "name", "album"] 

# Now that we have a method that returns us an array of column names, we can use the collection to create the attr_accessors of our Song class 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Metatprogramming our attr_accessors 
# We can tell our SOng class that it should have an attr_accessor name for each column name with the following 
lass Song
  def self.table_name
    #table_name code
  end

  def self.column_names
    #column_names code
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end
end 
# We iterate over the column names stored in the column_names class method 
# and set an attr_access for each one, making sure to convert the column name string into a symbol with the #to_sym method 
# since attr_accessors must be named with symboles
# Doing this we are writing code that writes code for us 
# We are seting a reader and writer method (attr_accessor) without explicitly naming each of these methods 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# STEP 3: Building an abstract #initialzie Method 
# Build the #initialize method for the Song class 
# We want it to be abstract, so that we can later remove it into a parent class that any other class can inherit from 

# We want to be able to create a new song like this 
song = Song.new(name: "Hello", album: "25")
song.name # => "Hello"
song.album # => "25" 
