require_relative 'db_connection'
require_relative 'searchable'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject
  extend Searchable
  extend Associatable

  def self.columns
    data = DBConnection.execute2(<<-SQL).first
      SELECT
       *
      FROM
        #{table_name}
    SQL
    data.map(&:to_sym)
  end

  def self.finalize!
    columns.each do |column|
      define_method(column) do
        attributes[column]
      end

      define_method("#{column}=") do |val|
        attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= name.tableize
  end

  def self.all
    data = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{table_name}
    SQL
    parse_all(data)
  end

  def self.parse_all(results)
    results.map{ |result| self.new(result) }
  end

  def self.find(id)
    data = DBConnection.execute(<<-SQL, id: id).first
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = :id
    SQL

    self.new(data) if data
  end

  def self.validate(method_name)
    validations << {name: method_name}
  end

  def self.validations
    @validations ||= []
  end

  def initialize(params = {})
    columns = self.class.columns
    params.each do |attr_name, value|
      unless columns.include?(attr_name.to_sym)
        raise("unknown attribute '#{attr_name}'")
      end

      send("#{attr_name}=", value)
    end
  end

  def check_validations
    self.class.validations.each do |validation|
      if validation[:params]
        send(validation[:name], validation[:params])
      else
        send(validation[:name])
      end
    end
  end

  def attributes
    @attributes ||= {}
  end

  def errors
    @errors ||= Hash.new{ |h,k| h[k] = [] }
  end

  def attribute_values
    self.class.columns.map{ |col| attributes[col] }
  end

  def insert
    columns = self.class.columns
    col_names = columns.drop(1).join(", ")
    question_marks = (["?"] * (columns.length - 1)).join(", ")
    DBConnection.execute(<<-SQL, *attribute_values.drop(1))
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    check_validations
    column = self.class.columns.map {|col_name| "#{col_name} = ?"}.join(", ")
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{column}
      WHERE
        id = ?
    SQL
  end

  def save
    check_validations
    unless errors.empty?
      errors.each{ |k,v| raise("#{k} error: #{v}")}
    end
    id ? update : insert
  end
end
