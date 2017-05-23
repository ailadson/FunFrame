require_relative '../phase7/controller_base'
require_relative './csrf_protection'

module Phase8
  class ControllerBase < Phase7::ControllerBase

    attr_reader :flash

    def initialize(req, res, route_params = {})
      super(req, res, route_params = {})
      protect_from_forgery :exception
    end

    def form_authenticity_token
      @csrf_protection.form_authenticity_token
    end

    def protect_from_forgery(reaction = :null)
      @csrf_protection = CSRFProtection.new(req, res)
      @csrf_protection.protect_from_forgery(reaction)
      @csrf_protection.verify_token(@params) if req.body
    end
  end
end
