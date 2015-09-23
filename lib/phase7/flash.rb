class Flash

  #ugh
  class Now
    def initialize(messages)
      @messages = messages
    end

    def []=(key, msg)
      @messages[key.to_s] = [msg, false]
    end

    def [](key)
      @messages[key.to_s][0] if @messages[key.to_s]
    end
  end

  attr_reader :now

  def initialize(req)
    @messages = request_flash(req) || {}
    @now = Now.new(@messages)
    pre_action_update
  end

  def request_flash(req)
    old_flash = req.cookies.find { |kookie| kookie.name == '_flash_rails_lite_app' }
    JSON.parse(old_flash.value) if old_flash
  end

  def []=(key, msg)
    @messages[key.to_s] = [msg, true]
  end

  def [](key)
    @messages[key.to_s][0] if @messages[key.to_s]
  end

  def pre_action_update
    @messages.each do |key, value|
      next if @messages[key].nil?
      @messages[key][1] = false
    end
  end

  def post_action_update
    @messages.each do |key, value|
      next if @messages[key].nil? || @messages[key][1]
      @messages.delete(key)
    end
  end

  def store_messages(res)
    new_flash = WEBrick::Cookie.new('_flash_rails_lite_app', @messages.to_json)
    res.cookies << new_flash
  end
end
