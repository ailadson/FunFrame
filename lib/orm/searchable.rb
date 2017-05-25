require_relative 'db_connection'

module Searchable
  def where(params)
    where_line = params.map{ |k,v| "#{k} = ?" }.join(" AND ")
    data = DBConnection.execute(<<-SQL, params.values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    self.parse_all(data)
  end
end
