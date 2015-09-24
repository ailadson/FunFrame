module RailsLite
end

def require_routes
  require_relative './router'
  require_relative './config/routes'
end

def require_base_classes
  require_relative './active_record_lite/sql_object.rb'
  require_relative './controllers/controller_base/controller_base.rb'
end

def start_server
  require_base_classes
  require_routes
  
  server = WEBrick::HTTPServer.new(Port: 3000)
  server.mount_proc('/') do |req, res|
    route = router.run(req, res)
  end
end

if __FILE__ == $PROGRAM_NAME
  command = ARGV[0]

  case command
  when "s"
    start_server
  end
end
