# Dynamic ORM Inheritance
# Explain why it is useful to have an ORM class from which other classes in your program can inherit
# Describe the code that is used to construct such a class

# Dynamic ORM provides a way to write an ORM that is almost entirely abstract 
# The methods we write that allow a given Ruby clcass and isntance to communicate with a database are not specific to any one class 

# We can define them in only once place 
# and make them available via inheritance to any other class 

# The Super class 
# Open up the interactive_record.rb 
# The interactive Record clsas contains almost all of the code responsible for communicating b/n our Ruby program and our database 
require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

def self.find_by_name(name)
  sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
  DB[:conn].execute(sql, name)
end

end


# The Child Class 
# lib/song.rb 
# inherits from Interactive Record 
# all of the methods defined in InteractiveRecord are available to Song 
require_relative "./interactive_record.rb"

class Song < InteractiveRecord

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end 

# The only code the Song class needs is the code to create the attr_accessors specific to itself 
# but even the method #column_names, inhertied from the super class 

# Our Code in Action 
# Open up the executable file in bin/run.

# We create a new Song instance 
# Remember, there is no initialize method defined in the Song class itself, it is inherited from Interactive Records class
song = Song.new(name: "Hello", album: "25")

# After the Song instance is created, info aboutt he song is printed out 
puts "song name: " + song.name
puts "song album: " + song.album

# Then we save it to the database
song.save

# To make sure it works this is used to serach the db for the newly created song 
puts Song.find_by_name("Hello") 

# When ruby bin/run is run in the terminal 
# You prdouce the following confirming that the song was saved 
song name: Hello
song album: 25
{"id"=>1, "name"=>"Hello", "album"=>"25"} 