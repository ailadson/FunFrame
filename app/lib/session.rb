require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    @cookie = req.cookies["_funframe_app"]
    @cookie = @cookie.nil? ? {} : JSON.parse(@cookie)
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    res.set_cookie("_funframe_app", { path: '/', value: @cookie.to_json })
  end
end
