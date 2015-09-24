require_relative 'searchable'
require_relative 'relation'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.singularize.constantize
  end

  def table_name
    return "humans" if class_name == "Human"
    class_name.tableize
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # Consider hash merge
    @class_name = options[:class_name] || name.to_s.camelcase
    @foreign_key = options[:foreign_key] || (name.to_s.underscore + "_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @foreign_key = options[:foreign_key] || (self_class_name.underscore + "_id").to_sym
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      f_key = send(options.foreign_key)

      statement = (<<-SQL)
        SELECT
            *
        FROM
          #{options.table_name}
        WHERE
          #{options.table_name}.#{options.primary_key} = ?
      SQL

      Relation.new(options.model_class, statement, [f_key])
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.name,options)

    define_method(name) do
      p_key = send(options.primary_key)

      statement = (<<-SQL)
        SELECT
          *
        FROM
          #{options.table_name}
        WHERE
          #{options.table_name}.#{options.foreign_key} = ?
      SQL

      Relation.new(options.model_class, statement, [p_key])
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      thru_opts = self.class.assoc_options[through_name]
      src_opts = thru_opts.model_class.assoc_options[source_name]
      p_key = send(thru_opts.primary_key)

      select_statement = "#{src_opts.table_name}.*"
      from_statement = "#{src_opts.table_name}"
      join_statement = ["#{thru_opts.table_name}"]
      on_statement = ["#{src_opts.table_name}.#{src_opts.primary_key} = #{thru_opts.table_name}.#{src_opts.foreign_key}"]
      where_statement = "#{thru_opts.table_name}.#{thru_opts.primary_key} = ?"


      statement = (<<-SQL)
        SELECT
          #{select_statement}
        FROM
          #{from_statement}
        JOIN
          #{join_statement[0]}
        ON
          #{on_statement[0]}
        WHERE
          #{thru_opts.table_name}.#{thru_opts.primary_key} = ?
      SQL

      Relation.new(thru_opts.model_class, statement, [p_key])
    end
  end
end
