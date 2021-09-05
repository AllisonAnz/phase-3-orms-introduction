class Song 
    ....
  def update
    sql = "UPDATE songs SET name = ?, album = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.album, self.id)
  end

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