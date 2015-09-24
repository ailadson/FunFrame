require 'json'
require 'webrick'

class Session
  def initialize(req)
    @cookie_value = request_cookie(req) || {}
  end

  def request_cookie(req)
    cookie = req.cookies.find { |kookie| kookie.name == '_rails_lite_app' }
    JSON.parse(cookie.value) if cookie
  end

  def [](key)
    @cookie_value[key]
  end

  def []=(key, val)
    @cookie_value[key] = val
  end

  def store_session(res)
    cookie = WEBrick::Cookie.new('_rails_lite_app', @cookie_value.to_json)
    res.cookies << cookie
  end
end
