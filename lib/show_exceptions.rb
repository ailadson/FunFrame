require 'erb'

class ShowExceptions
  attr_reader :app

  def initialize(app)
    @app = app
  end

  def call(env)
    begin
      app.call(env)
    rescue Exception => e
      res = Rack::Response.new
      res.status = 500
      res['Content-Type'] = 'text/html'
      res.write(render_exception(e))
      res.finish
    end
  end

  private

  def render_exception(e)
    @error = e
    path_to_erb = "views/templates/rescue.html.erb"
    erb_text = File.read(path_to_erb)
    ERB.new(erb_text).result(binding)
  end

end
