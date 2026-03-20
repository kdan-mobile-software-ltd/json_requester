# JsonRequester

[![Gem Version](https://badge.fury.io/rb/json_requester.svg?icon=si%3Arubygems)](https://badge.fury.io/rb/json_requester)

`JsonRequester` is a lightweight wrapper around Faraday for sending
JSON, form-encoded, and multipart HTTP requests.

## Requirements

- Ruby `>= 3.0.0`
- Faraday `2.x`

## Installation

### For Faraday 2.x

Install `json_requester` 2.x:

```bash
gem install json_requester -v '~> 2.0'
```

### For Faraday 1.x

If you still need Faraday 1.x, install `json_requester` 1.x:

```bash
gem install json_requester -v '~> 1.0'
```

## Usage

### Initialize a requester

```ruby
host = 'http://httpbingo.org'

requester = JsonRequester.new(
  host,
  timeout: 120,
  user_agent: 'My Agent 1.2'
)
```

Available initialization options:

- `timeout`: request timeout in seconds, default is `60`
- `user_agent`: custom user agent string
- `multipart`: enable multipart request middleware, default is `false`
- `ssl_verify`: enable SSL certificate verification, default is `true`

### Send JSON requests

Use `http_send` for regular JSON-based requests.

- `:get` sends params as query parameters
- other HTTP methods send params as a JSON body

```ruby
path = '/post-path'
headers = { 'Authorization' => 'Bearer token' }
params = {
  key_1: 'value_1',
  key_2: 'value_2'
}

response = requester.http_send(
  :post,
  path,
  params,
  headers,
  sort_params: true,
  content_type_charset: 'utf-8',
  need_response_header: true
)

puts response['status']
puts response['body']
puts response['headers'] if response.key?('headers')
```

### Send form-encoded requests

Use `form_send` for `application/x-www-form-urlencoded` requests.

```ruby
path = '/post-path'
headers = { 'Authorization' => 'Bearer token' }
params = {
  key_1: 'value_1',
  key_2: 'value_2'
}

form_response = requester.form_send(
  :post,
  path,
  params,
  headers,
  sort_params: true,
  need_response_header: true
)
```

### Send multipart requests

Use `multipart_form_send` for file uploads or multipart form data.

```ruby
multipart_requester = JsonRequester.new(host, multipart: true)

upload_params = {
  file: Faraday::Multipart::FilePart.new('path/to/file.txt', 'text/plain'),
  description: 'File upload example'
}

upload_response = multipart_requester.multipart_form_send(
  :post,
  '/upload_path',
  upload_params,
  { 'Authorization' => 'Bearer token' }
)
```

## Request Methods

- `http_send`: JSON body or query-parameter requests
- `form_send`: form-encoded requests
- `multipart_form_send`: multipart form requests

### Method overview

- `http_send`: uses query params for `:get`, and sends a JSON body for
  other HTTP methods
- `form_send`: sends requests as `application/x-www-form-urlencoded`
- `multipart_form_send`: sends multipart form data, typically for file
  uploads

`http_send`, `form_send`, and `multipart_form_send` accept HTTP verbs
such as:

- `:get`
- `:post`
- `:put`
- `:delete`

### Common options

- `sort_params`: controls whether query parameters are sorted before sending, default is `true`
- `content_type_charset`: used by `http_send` for JSON requests,
  default is `'utf-8'`
- `need_response_header`: when set to `true`, includes response
  headers in the returned result

## Security

Please see [SECURITY.md](SECURITY.md) for vulnerability reporting instructions.