require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'
require 'active_support/inflector'

class ControllerBase
  attr_reader :req, :res, :params, :resource_name

  def self.protect_from_forgery
    @@csfr_protection = true
  end

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @already_built_response = false
    @params = req.params.merge(route_params)
    @resource_name = self.class.name.split("Controller")[0].downcase
  end

  def already_built_response?
    return @already_built_response
  end

  def redirect_to(url)
    res.set_header('Location', url)
    res.status = 302
    session.store_session(res)
    @already_built_response = true
  end


  def render_content(content, content_type)
    raise "Cannot double render" if already_built_response?
    res.set_header('Content-Type', content_type)
    res.write(content)
    session.store_session(res)
    @already_built_response = true
  end

  def render(template_name)
    path_to_erb = "views/#{resource_name}/#{template_name}.html.erb"
    erb_text = File.read(path_to_erb)
    html = ERB.new(erb_text).result(binding)
    render_content(html, 'text/html')
  end

  def session
    @session ||= Session.new(req)
  end

  def flash
    @flash ||= Flash.new(req)
  end

  def invoke_action(name)
    if protect_from_forgery? && !req.get?
      check_authenticity_token
    else
      form_authenticity_token
    end

    send(name)
    render(name) unless already_built_response?
  end

  def protect_from_forgery?
    @@csfr_protection
  end

  def form_authenticity_token
    @token ||= SecureRandom.urlsafe_base64(16)
    res.set_cookie('authenticity_token', value: @token, path: '/')
    @token
  end

  def check_authenticity_token
    token = req.cookies["authenticity_token"]
    unless token && token == params["authenticity_token"]
      raise "Invalid authenticity token"
    end
  end
end
