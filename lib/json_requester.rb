require 'faraday'
require 'json'

class JsonRequester
  attr_reader :host, :conn

  def initialize(host)
    @host = host
    @conn = init_conn
  end

  def http_send(http_method, path, params={}, headers={})
    if http_method == :get
      normal_send(http_method, path, params, headers)
    else
      json_send(http_method, path, params, headers)
    end
  end

  def normal_send(http_method, path, params={}, headers={})
    res = @conn.send(http_method) do |req|
      req.url path
      req.params = params if object_present?(params)
      req.headers = headers if object_present?(headers)
    end
    process_response(res)
  rescue => e
    error_response(e)
  end

  def json_send(http_method, path, params={}, headers={})
    res = @conn.send(http_method) do |req|
      req.url path
      req.headers = headers if object_present?(headers)
      req.headers['Content-Type'] = 'application/json'
      req.body = params.to_json if object_present?(params)
    end
    process_response(res)
  rescue => e
    error_response(e)
  end

  private

  def init_conn
    Faraday.new(url: host) do |faraday|
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
