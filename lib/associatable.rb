require_relative 'searchable'
require_relative 'assoc_options'
require_relative 'db_connection'

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = BelongsToOptions.new(name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.foreign_key)

      options.model_class.where(options.primary_key => key_val).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      key_val = self.send(options.primary_key)

      options.model_class.where(options.foreign_key => key_val)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_primary = through_options.primary_key
      through_foreign = through_options.foreign_key

      source_table = source_options.table_name
      source_primary = source_options.primary_key
      source_foreign = source_options.foreign_key

      key_val = self.send(through_foreign)
      results = DBConnection.execute(<<-SQL, key_val)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_foreign} = #{source_table}.#{source_primary}
        WHERE
          #{through_table}.#{through_primary} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

end

