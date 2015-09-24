require 'uri'

class Params
  def initialize(req, route_params = {})
    @params = route_params
    @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
    @params.merge!(parse_www_encoded_form(req.body)) if req.body
  end

  def [](key)
    @params[key.to_s] || @params[key.to_sym]
  end

  def to_s
    @params.to_s
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  def parse_www_encoded_form(www_encoded_form)
    p_hash = {}

    kv_pairs = URI::decode_www_form(www_encoded_form)

    kv_pairs.each do |kv_pair|
      keys = parse_key(kv_pair[0])
      val = kv_pair[1]
      current_hash = p_hash

      keys.each_with_index do |k, i|

        if i == keys.length - 1
          current_hash[k] = val
        else
          current_hash[k] ||= {}
          current_hash = current_hash[k]
        end
      end
    end
    p_hash
  end

  def parse_key(key)
      key.split(/\]\[|\[|\]/)
  end
end
