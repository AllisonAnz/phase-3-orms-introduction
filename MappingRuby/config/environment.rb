# It is the responsibility of the whole program to create and establish the database

require 'sqlite3'
require_relative '../lib/song.rb'

# Set up a constant, DB equal to a hash that contains our connection to the database 
# In our lib/song.rb file, we can access the DB constant and the 
# database connection that it holds like this 
# DB[:conn]

DB = {:conn => SQLite3::Database.new("db/music.db")} 

puts "working"