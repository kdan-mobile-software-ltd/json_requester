# JsonRequester

### A Wrapper of Faraday Gem

### Install

    gem install json_requester

### How to Use

    requester = JsonRequester.new(host)
    res = requester.http_send(http_method, path, params, headers)
    puts res['status']  # 200
    puts res['body']    # { foo: 'bar' }

    puts res['status']  # 500
    puts res['message'] # invalid method
