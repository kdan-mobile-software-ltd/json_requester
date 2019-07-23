# JsonRequester

### A Wrapper of Faraday Gem

### How to Use

* init requester
`requester = JsonRequester.new([host])`

* http request
`requester.http_send([http_method], [path], [params], [headers])`