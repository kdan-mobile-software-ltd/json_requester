require 'faraday'
require 'json'

class JsonRequester
  attr_reader :host, :conn

  def initialize(host, multipart: false)
    @host = host
    @multipart = multipart
  end

  def http_send(http_method, path, params={}, headers={})
    if http_method == :get
      normal_send(http_method, path, params, headers)
    else
      json_send(http_method, path, params, headers)
    end
  end

  def normal_send(http_method, path, params={}, headers={})
    conn = init_conn
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.params = params if object_present?(params)
    end
    process_response(res)
  rescue => e
    error_response(e)
  end

  def json_send(http_method, path, params={}, headers={})
    conn = init_conn
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

  def form_send(http_method, path, params={}, headers={})
    conn = init_conn
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded ;charset=utf-8'
      req.body = URI.encode_www_form(params) if object_present?(params)
    end
    process_response(res)
  rescue => e
    error_response(e)
  end

  def multipart_form_send(http_method, path, params={}, headers={})
    conn = init_conn
    res = conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.body = params if object_present?(params)
    end
    process_response(res)
  end

  private

  def init_conn
    Faraday.new(url: host) do |faraday|
      faraday.request :multipart if @multipart  # multipart form POST request
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to $stdout
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def process_response(response)
    result = {'status' => response.status}
    begin
      body = JSON.parse(response.body)
      body = body.is_a?(Hash) ? body : {'body' => body}
      body['body_status'] = body.delete('status') unless body['status'].is_a?(Integer)
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
