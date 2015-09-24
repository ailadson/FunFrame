require_relative 'db_connection'

class Relation
  include Enumerable

  def initialize(model_class, statement, escaped_values = [])
    @model_class = model_class
    @statement = statement
    @escaped_values = escaped_values
    @cache = nil
  end

  def each
    models = @cache || load
    models.each{ |model| yield(model) }
  end

  def load
    data = DBConnection.execute(@statement, *@escaped_values)
    @model_class.parse_all(data)
  end

  def where(params)
    where_statement = params.keys.map { |name| "#{name} = ?" }.join(" AND ")
    statement += " AND #{where_statement}"
  end

  def inspect
    @cache || load
  end
end
