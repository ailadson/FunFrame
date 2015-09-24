require_relative 'relation'

module Searchable
  def where(params)
    where_statement = params.keys.map { |name| "#{name} = ?" }.join(" AND ")

    data = <<-SQL
      SELECT
        *
      FROM
       #{self.table_name}
      WHERE
        #{where_statement}
    SQL

    Relation.new(self.class, where_statement, params.values)
  end
end
