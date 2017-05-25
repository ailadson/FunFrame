
class Static
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    if req.path.index('/public/') == 0
      res = Rack::Response.new
      begin
        path = req.path[1..-1]
        # mime =
        # res['Content-Type'] = mime
        res.write(File.read(path))
        res.finish
      rescue
        res.status = 404
        res.finish
      end
    else
      app.call(env)
    end
  end
end
