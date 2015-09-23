class Flash
  def initialize(req)
    @messages = request_flash(req) || {}
  end

  def request_flash(req)
    old_flash = req.cookies.find { |kookie| kookie.name == '_flash_rails_lite_app' }
    JSON.parse(old_flash.value) if old_flash
  end

  def []=(key, msg)
    @messages[key] = [msg, true]
  end

  def [](key)
    @messages[key][0]
  end

  def pre_action_update
    @messages.each do |key, value|
      next if @messages[key].nil?
      @messages[key][1] = false
    end
    p "Pre_update: #{@messages}"
  end

  def post_action_update
    @messages.each do |key, value|
      next if @messages[key].nil? || @messages[key][1]
      @messages.delete(key)
    end
    p "Post_update: #{@messages}"
  end

  def store_messages(res)
    new_flash = WEBrick::Cookie.new('_flash_rails_lite_app', @messages.to_json)
    res.cookies << new_flash
  end
end
