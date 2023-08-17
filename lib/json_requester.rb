require 'faraday'
require 'json'

class JsonRequester
  attr_reader :host, :conn

  def initialize(host, multipart: false, ssl_verify: true, timeout: 60)
    @host = host
    @multipart = multipart
    @ssl_verify = ssl_verify
    @timeout = timeout
  end

  def http_send(http_method, path, params={}, headers={}, sort_params: true)
    puts "send #{http_method} reqeust to #{@host} with\npath: #{path}\nparams: #{params}\nheaders: #{headers}"
    if http_method == :get
      normal_send(http_method, path, params, headers, sort_params: sort_params)
    else
      json_send(http_method, path, params, headers, sort_params: sort_params)
    end
  end

  def normal_send(http_method, path, params={}, headers={}, sort_params: true)
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.params = params if object_present?(params)
    end
    process_response(res)
  rescue => e
    error_response(e)
  end

  def json_send(http_method, path, params={}, headers={}, sort_params: true)
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.headers['Content-Type'] = 'application/json;charset=utf-8'
      req.body = params.to_json if object_present?(params)
    end
    process_response(res)
  rescue => e
    error_response(e)
  end

  def form_send(http_method, path, params={}, headers={}, sort_params: true)
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded;charset=utf-8'
      req.body = URI.encode_www_form(params) if object_present?(params)
    end
    process_response(res)
  rescue => e
    error_response(e)
  end

  def multipart_form_send(http_method, path, params={}, headers={}, sort_params: true)
    conn = init_conn(sort_params: sort_params)
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.body = params if object_present?(params)
    end
    process_response(res)
  end

  private

  def init_conn(sort_params: true)
    # https://lostisland.github.io/faraday/#/customization/index?id=order-of-parameters
    Faraday::NestedParamsEncoder.sort_params = sort_params # faraday default is true

    Faraday.new(url: host, ssl: { verify: @ssl_verify }) do |faraday|
      faraday.request :multipart if @multipart  # multipart form POST request
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      faraday.options.timeout = @timeout
    end
  end

  def process_response(response)
    result = {'status' => response.status}
    begin
      body = JSON.parse(response.body)
      body = body.is_a?(Hash) ? body : {'body' => body}
      body['body_status'] = body.delete('status') unless body['status'].nil?
    rescue
      body = {'body' => response.body}
    end
    result.merge(body)
  end

  def error_response(err)
    {'status' => 500, 'message' => "#{err.class.name}: #{err.message}"}
  end

  def object_present?(object)
    !(object.nil? || object.empty?)
  end

end
