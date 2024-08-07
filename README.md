# JsonRequester

### A Wrapper of Faraday Gem

### Install

```bash
$ gem install json_requester
```

### How to Use

```ruby
  host = 'http://httpbingo.org'
  # `timeout` at Faraday gem default is 60 secs.
  # `user_agent` at Faraday gem default is like "Faraday v1.10.0", it would be deep_merge at Faraday default setting.
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
  res = requester.http_send(http_method, path, params, headers, sort_params: true, content_type_charset: 'utf-8')
  
  # http response code
  puts res['status'] # 200, 404, .. etc
  # the response JSON body
  puts res['body'] # { foo: 'bar' }  
```