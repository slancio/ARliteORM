require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |key| "#{key} = ?"}.join(" AND ")
    
    row = DBConnection.execute(<<-SQL, *params.values)
            SELECT
              *
            FROM
              #{table_name}
            WHERE
              #{where_line}
          SQL
    return [] if row.empty?
    parse_all(row)   
  end
end

class SQLObject
  extend Searchable
end
