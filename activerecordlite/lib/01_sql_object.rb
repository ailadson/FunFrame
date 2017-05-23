require_relative 'db_connection'
require 'active_support/inflector'

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col){ attributes[col] }
      define_method("#{col}="){ |val| attributes[col] = val }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
        SELECT
          *
        FROM
          #{self.table_name}
    SQL

    self.parse_all(data)
  end

  def self.parse_all(results)
    results.map{ |d| self.new(d) }
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id).first
        SELECT
          *
        FROM
          #{self.table_name}
        WHERE
          id = ?
    SQL
    data.nil? ? data : self.new(data)
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute '#{k}'" unless self.respond_to?("#{k}=")
      self.send("#{k}=", v)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    col_names = self.class.columns.join(", ")
    question_marks = (["?"] * self.class.columns.length).join(", ")
    DBConnection.execute(<<-SQL, attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_assignments = self.class.columns.map{ |col| "#{col} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, attribute_values + [self.id])
      UPDATE
        #{self.class.table_name}
      SET
        #{col_assignments}
      WHERE
        id = ?
    SQL
  end

  def save
    self.id.nil? ? self.insert : self.update
  end
end
