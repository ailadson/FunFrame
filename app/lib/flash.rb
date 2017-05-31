require 'json'

class FlashNow
  def initialize(cookie)
    @cookie = cookie
  end

  def [](key)
    key = key.to_s
    @cookie[key].nil? ? nil : @cookie[key]['value']
  end

  def []=(key, val)
    key = key.to_s
    @cookie[key] = { 'value' => val, 'life' => 1 }
  end
end

class Flash
  attr_accessor :now

  def initialize(req)
    @cookie = req.cookies["_rails_lite_app_flash"]
    @cookie = @cookie.nil? ? {} : JSON.parse(@cookie)
    @now = FlashNow.new(@cookie)
  end

  def [](key)
    key = key.to_s
    @cookie[key].nil? ? nil : @cookie[key]['value']
  end

  def []=(key, val)
    key = key.to_s
    @cookie[key] = { 'value' => val, 'life' => 2 }
  end

  def store_flash(res)
    @cookie.each { |_,v| v['life'] -= 1 }
    @cookie = @cookie.select do |_,v|
      v['life'] > 0
    end
    res.set_cookie("_rails_lite_app_flash", {
      path: '/',
      value: @cookie.to_json
    })
  end
end
