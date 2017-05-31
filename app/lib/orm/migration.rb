require_relative 'db_connection'

class Migration
  #TODO

  def initialize
    @create_line = ""
  end

  def create_table(name, )
    DBConnection.execute(<<-SQL)
      CREATE TABLE #{name.to_s} (
      )
    SQL
  end

  def add_column()
  end

  def remove_column()
  end

  def change_column()
  end

  def get_type(symbol)
    case symbol
    when :string
      'VARCHAR(255)'
    when :
    end
  end
end
