class CSRFProtection
  attr_reader :form_authenticity_token

  def initialize(req, res)
    @req = req
    @res = res
    @protected = false
    @token = request_token
  end

  def request_token
    token = @req.cookies.find{ |kookie| kookie.name == '_auth_rails_lite_app' }
    return token.value if token
  end

  def protect_from_forgery(reaction)
    @csrf_prote
    @protected = true
    @reaction = reaction
    @form_authenticity_token = SecureRandom.urlsafe_base64
    store_token
  end

  def respond_to_attack
    case @reaction
      when :null
        false
      when :exception
        raise BadAuthenticationException.new("Invalid Authentication Token")
    end
  end

  def verify_token(params)
    return if !@protected
    respond_to_attack unless params[:authenticity_token] == @token
  end

  def store_token
    token = WEBrick::Cookie.new('_auth_rails_lite_app', @form_authenticity_token)
    @res.cookies << token
  end

  class BadAuthenticationException < Exception
  end
end
