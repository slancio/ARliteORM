require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    table = DBConnection.execute2("SELECT * FROM #{table_name}")
    columns = []
    table[0].each do |col|
      columns << col.to_sym
    end
    columns
  end

  def self.finalize!
    columns.each do |col|
      define_method("#{col}=") { |args| attributes[col] = args }
      define_method(col) { attributes[col] }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.tableize
  end

  def self.all
    parse_all(DBConnection.execute(<<-SQL)
              SELECT
                #{table_name}.*
              FROM
                #{table_name}
              SQL
              )
  end

  def self.parse_all(results)
    results.map { |row| self.new(row) }
  end

  def self.find(id)
    row = DBConnection.execute(<<-SQL, id)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
      WHERE
        #{table_name}.id = ?
    SQL
    return nil if row.empty?
    parse_all(row).first
  end

  def initialize(params = {})
    params.each do |column, value|
      unless self.class.columns.include? column.to_sym
        raise "unknown attribute '#{column}'"
      end
      send("#{column.to_sym}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |name| send(name) }
  end

  def insert
    col_names = self.class.columns.join(', ')
    question_marks = (["?"] * self.class.columns.length).join(', ')

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    updates = self.class.columns.map { |attr| "#{attr} = ?" }.join(', ')
    DBConnection.execute(<<-SQL, *attribute_values, id)
      UPDATE
        #{self.class.table_name}
      SET
        #{updates}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
