class Dog
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = %{
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY, 
        name TEXT, 
        breed TEXT);
      }

    DB[:conn].execute(sql);
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs;"
    DB[:conn].execute(sql);
  end

  def self.create(dog)
    dog = self.new(name: dog[:name], breed: dog[:breed]);
    dog.save
    dog
  end

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    dog = self.new(id: row[0], name: row[1], breed: row[2]);
    dog.save
    dog
  end

  def self.find_by_id(id)
    # find the dog in the database given the id
    # return a new instance of the Dog class
    sql = <<-SQL
      SELECT * FROM dogs 
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id)[0]
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM dogs 
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_or_create_by(name:, breed:)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = <<-SQL
      SELECT * FROM dogs 
      WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, name, breed)[0]
    puts "Row >> #{row}"
    
    if (row) then 
      self.new(id: row[0], name: row[1], breed: row[2])
    else 
      self.new(name: name, breed: breed).save
    end
  end

  def save
    if (self.id) then 
      update
    else
      sql = %{
        INSERT OR REPLACE INTO dogs (name, breed) 
        VALUES (?, ?);
      }

      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  end

  def update
    sql = %{
      UPDATE dogs 
      SET name = ?, breed = ? 
      WHERE id = ?;
    }

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end