# By App Academy

# require 'sqlite3'
require 'pg'
require_relative '../../db/config.rb'

# https://tomafro.net/2010/01/tip-relative-paths-with-file-expand-path
ROOT_FOLDER = File.join(File.dirname(__FILE__), '..', '..', 'db')
# CONFIG_FILE = File.join(ROOT_FOLDER, 'config.rb')
SQL_FILE = File.join(ROOT_FOLDER, DB_CONFIG::INIT_FILE)
DB_FILE = File.join(ROOT_FOLDER, 'funframe.db')


class DBConnection
  def self.open
    # @db = SQLite3::Database.new(db_file_name)
    # @db.results_as_hash = true
    # @db.type_translation = true
    uri = URI.parse(ENV['DATABASE_URL'] || "postgres://localhost/#{DB_CONFIG::DATABASE_NAME}")
    @db = PG.connect(uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password)
    @db.type_map_for_results = PG::BasicTypeMapForResults.new @db

    @db
  end

  def self.reset
    DBConnection.open
    # commands = [
    #   "rm '#{DB_FILE}'",
    #   "cat '#{SQL_FILE}' | psql '#{DB_FILE}'"
    # ]
    #
    # commands.each { |command| `#{command}` }
  end

  def self.instance
    reset if @db.nil?

    @db
  end

  def self.execute(*args)
    print_query(*args)
    map_to_hash(instance.exec(*args))
  end

  def self.execute3(*args)
    # print_query(*args)
    instance.exec(*args)
  end

  def self.execute2(*args)
    # print_query(*args)
    result = instance.exec(*args)
    data = map_to_hash(result)
    data.unshift(result.fields)
  end

  def self.last_insert_row_id
    instance.last_insert_row_id
  end

  def self.map_to_hash(result)
    result.values.map do |attr|
      obj = {}
      result.fields.each_with_index{ |val, i| obj[val.to_sym] = attr[i] }
      obj
    end
  end

  private

  def self.print_query(query, *interpolation_args)
    return
    puts '--------------------'
    puts query
    unless interpolation_args.empty?
      puts "interpolate: #{interpolation_args.inspect}"
    end
    puts '--------------------'
  end
end
