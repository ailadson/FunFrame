require 'active_support'
require 'active_support/core_ext'
require 'erb'

require_relative 'session'
require_relative 'params'

class ControllerBase
  attr_reader :req, :res, :params, :flash

  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
    @params = Params.new(req, route_params)
    @flash = Flash.new(req)
    protect_from_forgery :exception
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise("Cannot render twice.") if @already_built_response
    @already_built_response = true

    session.store_session(res)
    flash.post_action_update
    flash.store_messages(res)

    @res.status = 302
    @res.header["location"] = url
  end

  def render(template_name)
    controller_name = self.class.name.underscore
    erb_content = File.read("views/#{controller_name}/#{template_name}.html.erb")
    content = ERB.new(erb_content).result(binding)
    render_content(content, "text/html")
  end

  def session
    @session ||= Session.new(req)
  end

  def render_content(content, content_type)
      raise("Cannot render twice.") if @already_built_response
      @already_built_response = true

      session.store_session(res)
      flash.post_action_update
      flash.store_messages(res)

      @res.content_type = content_type
      @res.body = content
  end

  def invoke_action(name)
    send(name)
    render(name) unless already_built_response?
  end

  def form_authenticity_token
    @csrf_protection.form_authenticity_token
  end

  def protect_from_forgery(reaction = :null)
    @csrf_protection = CSRFProtection.new(req, res)
    @csrf_protection.protect_from_forgery(reaction)
    @csrf_protection.verify_token(@params) if req.body
  end

  def const_missing(name)
    require_relative ".../models/#{name.downcase.singularize}.rb"
    name
  end
end
