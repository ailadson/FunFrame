require 'rack'
require_relative '../lib/orm/sql_object.rb'
require_relative '../lib/controller_base.rb'
require_relative '../lib/router'
require_relative '../lib/static'
require_relative '../lib/show_exceptions'

def require_directory(dir)
  dir_name = File.dirname(__FILE__)
  Dir["#{dir_name}/../#{dir}/*.rb"].each do |file|
    require_relative file[dir_name.length + 1..-1]
  end
end

require_directory('models')
require_directory('controllers')


router = Router.new
router.draw do
  eval(File.read('routes.rb'))
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  # use ShowExceptions
  use Static
  run app
end.to_app

Rack::Server.start(
 app: app,
 Port: ENV['PORT'] || 3000
)
