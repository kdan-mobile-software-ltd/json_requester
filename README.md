# JsonRequester

### A Wrapper of Faraday Gem

### Install

If you want to use faraday 1.x version, install json_requester 1.x version:
```bash
$ gem install json_requester -v '~> 1.0'
```

If you want to use faraday 2.x version, install json_requester 2.x version:
```bash
$ gem install json_requester -v '~> 2.0'
```

### How to Use

```ruby
  # initialize the JsonRequester class
  host = 'http://httpbingo.org'
  # `timeout` at Faraday gem default is 60 secs.
  # `user_agent` at Faraday gem default is like "Faraday v1.10.0", it would be deep_merge at Faraday default setting.
  # `multipart` option enables multipart form requests (for file uploads), default is false
  # `ssl_verify` controls SSL certificate verification, default is true
  requester = JsonRequester.new(host, timeout: 120, user_agent: 'My Agent 1.2')
  
  http_method = :get  # :get / :post / :put / :delete
  path = ''
  headers = { 'Authorization' => 'Bearer token' }

  # The `:get` method will use query params;
  # Other HTTP methods will use JSON body to request.
  params = {
    key_1: 'value_1',
    key_2: 'value_2'
  }

  # Request by using JSON body or query params, use the `http_send` method.
  # other methods: `form_send`, `multipart_form_send`
  # `sort_params` at Faraday gem default is true.
  # `content_type_charset` default is 'utf-8', this will add ; charset=utf-8 after `Content-Type` header (ex. `Content-Type=application/json; charset=utf-8`).
  # `need_response_header` when set to true will include response headers in the result
  res = requester.http_send(http_method, path, params, headers, sort_params: true, content_type_charset: 'utf-8')
  
  # http response code
  puts res['status'] # 200, 404, .. etc
  # the response JSON body
  puts res['body'] # { foo: 'bar' }

  # If need_response_header is true, you can access response headers
  puts res['headers'] if res.key?('headers')

  # For form-encoded requests (application/x-www-form-urlencoded)
  form_res = requester.form_send(:post, '/post', params, headers)
  
  # For file uploads or multipart form requests
  # First initialize with multipart: true
  multipart_requester = JsonRequester.new(host, multipart: true)
  
  # Then prepare your payload with file objects
  upload_params = {
    file: Faraday::Multipart::FilePart.new('path/to/file.txt', 'text/plain'),
    description: 'File upload example'
  }
  
  # Send multipart request
  upload_res = multipart_requester.multipart_form_send(:post, '/upload_path', upload_params, headers)
```