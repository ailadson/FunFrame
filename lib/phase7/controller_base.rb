require_relative '../phase6/controller_base'
require_relative './flash'

module Phase7
  class ControllerBase < Phase6::ControllerBase
    def initialize(req, res, route_params = {})
      p "===================================="
      super(req, res, route_params = {})
      flash.pre_action_update
    end

    def invoke_action(name)
      # flash.pre_action_update
      super(name)
    end

    def redirect_to(url)
      super(url)
      flash.post_action_update
      flash.store_messages(res)
    end

    def render_content(content, content_type)
      super(content, content_type)
      flash.post_action_update
      flash.store_messages(res)
    end

    def flash
      @flash ||= Flash.new(req)
    end
  end
end
