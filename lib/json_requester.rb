require 'faraday'
require 'faraday/multipart'
require 'json'

class JsonRequester
  attr_reader :host, :conn

  def initialize(host, multipart: false, ssl_verify: true, timeout: 60, user_agent: '')
    @host = host
    @multipart = multipart
    @ssl_verify = ssl_verify
    @timeout = timeout
    @user_agent = user_agent.strip.to_s
  end

  def http_send(http_method, path, params={}, headers={}, sort_params: true, need_response_header: false, content_type_charset: 'utf-8')
    puts "send #{http_method} request to #{@host} with\npath: #{path}\nparams: #{params}\nheaders: #{headers}"
    if http_method == :get
      normal_send(http_method, path, params, headers, sort_params: sort_params, need_response_header: need_response_header)
    else
      json_send(http_method, path, params, headers, sort_params: sort_params, need_response_header: need_response_header, content_type_charset: content_type_charset)
    end
  end

  def normal_send(http_method, path, params={}, headers={}, sort_params: true, need_response_header: false)
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.params = params if object_present?(params)
    end
    process_response(res, need_response_header: need_response_header)
  rescue => e
    error_response(e)
  end

  def json_send(http_method, path, params={}, headers={}, sort_params: true, need_response_header: false, content_type_charset: 'utf-8')
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.headers['Content-Type'] = object_present?(content_type_charset) ? "application/json;charset=#{content_type_charset}" : 'application/json'
      req.body = params.to_json if object_present?(params)
    end
    process_response(res, need_response_header: need_response_header)
  rescue => e
    error_response(e)
  end

  def form_send(http_method, path, params={}, headers={}, sort_params: true, need_response_header: false)
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8'
      req.body = URI.encode_www_form(params) if object_present?(params)
    end
    process_response(res, need_response_header: need_response_header)
  rescue => e
    error_response(e)
  end

  def multipart_form_send(http_method, path, params={}, headers={}, sort_params: true, need_response_header: false)
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.body = params if object_present?(params)
    end
    process_response(res, need_response_header: need_response_header)
  end

  private

  def init_conn(sort_params: true)
    # https://lostisland.github.io/faraday/#/customization/index?id=order-of-parameters
    Faraday::NestedParamsEncoder.sort_params = sort_params # faraday default is true
    Faraday.default_connection_options = { headers: { user_agent: @user_agent } } unless @user_agent.empty?
    options = { 
      url: host,
      ssl: { verify: @ssl_verify }
    }

    Faraday.new(options) do |faraday|
      faraday.request :multipart if @multipart  # multipart form POST request
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.options.timeout = @timeout
    end
  end

  def process_response(response, need_response_header: false)
    result = {'status' => response.status}
    begin
      body = JSON.parse(response.body)
      body = body.is_a?(Hash) ? body : {'body' => body}
      body['body_status'] = body.delete('status') unless body['status'].nil?
    rescue
      body = {'body' => response.body}
    end
    result.merge!(body)
    result['headers'] = response.headers.to_h if need_response_header
    result
  end

  def error_response(err)
    { 'status' => 500, 'message' => "#{err.class.name}: #{err.message}" }
  end

  def object_present?(object)
    # Ref: https://github.com/rails/rails/blob/v7.1.4.2/activesupport/lib/active_support/core_ext/object/blank.rb#L25
    # active_support present? method
    !object_blank?(object)
  end

  def object_blank?(object)
    # Ref: https://github.com/rails/rails/blob/v7.1.4.2/activesupport/lib/active_support/core_ext/object/blank.rb#L18
    # active_support blank? method
    return true if object.nil?
    object.respond_to?(:empty?) ? !!object.empty? : false
  end

end
