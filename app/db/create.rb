require_relative './config.rb'
require 'uri'
require 'pg'

uri = URI.parse(ENV['DATABASE_URL'] || "postgres://localhost/postgres")

conn = PG.connect(
  uri.hostname, uri.port, nil, nil, uri.path[1..-1], uri.user, uri.password
)
conn.exec(File.read("#{File.dirname(__FILE__)}/init.sql"))
conn.finish
