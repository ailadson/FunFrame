require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = {}
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
      @params.merge!(route_params)
    end

    def merge_request_body(req)
      if req.query_string
        query_hash = parse_www_encoded_form(req.query_body)
        @params.merge!(query_hash)
      end
    end

    def merge_query_string(req)
      if req.query_string
        query_hash = parse_www_encoded_form(req.query_string)
        @params.merge!(query_hash)
      end
    end

    def [](key)
      @params[key.to_s] || @params[key.to_sym]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
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
      p p_hash
      p_hash
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      if key.include?("[")
        key.split(/\]\[|\[|\]/)
      else
        [key]
      end
    end

  end
end
