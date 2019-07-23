# Requester

### A Wrapper of Faraday Gem

### How to Use

* init requester
`requester = Requester.new([host])`

* http request
`requester.http_send([http_method], [path], [params], [headers])`