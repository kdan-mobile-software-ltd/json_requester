require 'spec_helper'

RSpec.describe JsonRequester do
  let(:host) { 'http://example.com' }
  let(:requester) { JsonRequester.new(host) }
  let(:requester_with_overide_user_agent) { JsonRequester.new(host, user_agent: 'test_agent') }
  
  describe '#initialize' do
    it 'initializes with default values' do
      expect(requester.host).to eq(host)
    end

    it 'initializes with custom parameters' do
      custom_requester = JsonRequester.new(host, multipart: true, ssl_verify: false, timeout: 120, user_agent: 'Test Agent')
      expect(custom_requester.host).to eq(host)
    end
  end

  describe '#http_send' do
    context 'when method is GET' do
      it 'calls normal_send' do
        expect(requester).to receive(:normal_send).with(:get, '/test', {a: 1}, {}, sort_params: true, need_response_header: false)
        requester.http_send(:get, '/test', {a: 1}, {})
      end
    end

    context 'when method is not GET' do
      it 'calls json_send' do
        expect(requester).to receive(:json_send).with(:post, '/test', {a: 1}, {}, sort_params: true, need_response_header: false, content_type_charset: 'utf-8')
        requester.http_send(:post, '/test', {a: 1}, {})
      end
    end
  end

  describe '#normal_send' do
    let(:success_response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}', headers: {'Content-Type' => 'application/json'}) }
    
    before do
      allow(requester).to receive(:init_conn).and_return(Faraday)
      allow(Faraday).to receive(:get).and_yield(request_double).and_return(success_response)
    end
    
    let(:request_double) do
      double('request').tap do |request|
        allow(request).to receive(:url)
        allow(request).to receive(:headers=)
        allow(request).to receive(:params=)
      end
    end
    
    it 'sends a normal request and processes response' do
      expect(requester).to receive(:process_response).with(success_response, need_response_header: false)
      requester.normal_send(:get, '/test', {q: 'search'}, {'Authorization' => 'Bearer token'})
    end
    
    it 'handles exceptions properly' do
      allow(Faraday).to receive(:get).and_raise(StandardError.new('Network error'))
      expect(requester).to receive(:error_response).with(instance_of(StandardError))
      requester.normal_send(:get, '/test')
    end
  end

  describe '#json_send' do
    let(:success_response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}', headers: {'Content-Type' => 'application/json'}) }
    
    before do
      allow(requester).to receive(:init_conn).and_return(Faraday)
      allow(Faraday).to receive(:post).and_yield(request_double).and_return(success_response)
    end
    
    let(:request_double) do
      double('request').tap do |request|
        allow(request).to receive(:url)
        allow(request).to receive(:headers=)
        allow(request).to receive(:headers).and_return({})
        allow(request).to receive(:[]=)
        allow(request).to receive(:body=)
      end
    end
    
    it 'sends a json request and processes response' do
      expect(requester).to receive(:process_response).with(success_response, need_response_header: false)
      requester.json_send(:post, '/test', {data: 'test'}, {'Authorization' => 'Bearer token'})
    end
    
    it 'sets content type header with charset' do
      expect(request_double.headers).to receive(:[]=).with('Content-Type', 'application/json;charset=utf-8')
      requester.json_send(:post, '/test', {data: 'test'})
    end
  end

  describe '#form_send' do
    let(:success_response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}', headers: {'Content-Type' => 'application/json'}) }
    
    before do
      allow(requester).to receive(:init_conn).and_return(Faraday)
      allow(Faraday).to receive(:post).and_yield(request_double).and_return(success_response)
    end
    
    let(:request_double) do
      double('request').tap do |request|
        allow(request).to receive(:url)
        allow(request).to receive(:headers=)
        allow(request).to receive(:headers).and_return({})
        allow(request).to receive(:[]=)
        allow(request).to receive(:body=)
      end
    end
    
    it 'sends a form request and processes response' do
      expect(requester).to receive(:process_response).with(success_response, need_response_header: false)
      requester.form_send(:post, '/test', {data: 'test'}, {'Authorization' => 'Bearer token'})
    end
    
    it 'sets correct content type for form' do
      expect(request_double.headers).to receive(:[]=).with('Content-Type', 'application/x-www-form-urlencoded;charset=utf-8')
      requester.form_send(:post, '/test', {data: 'test'})
    end
  end

  describe '#multipart_form_send' do
    let(:success_response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}', headers: {'Content-Type' => 'application/json'}) }
    
    before do
      allow(requester).to receive(:init_conn).and_return(Faraday)
      allow(Faraday).to receive(:post).and_yield(request_double).and_return(success_response)
    end
    
    let(:request_double) do
      double('request').tap do |request|
        allow(request).to receive(:url)
        allow(request).to receive(:headers=)
        allow(request).to receive(:body=)
      end
    end
    
    it 'sends a multipart form request and processes response' do
      expect(requester).to receive(:process_response).with(success_response, need_response_header: false)
      file_path = File.join(File.dirname(__FILE__), 'fixtures', 'sample.txt')
      requester.multipart_form_send(:post, '/test', {data: 'test', file: Faraday::Multipart::FilePart.new(file_path, 'text/plain')})
    end
  end

  describe '#process_response' do
    let(:response) { instance_double(Faraday::Response, status: 200, body: '{"result": "success"}', headers: {'Content-Type' => 'application/json'}) }
    
    it 'processes successful JSON response' do
      result = requester.send(:process_response, response)
      expect(result).to include('status' => 200, 'result' => 'success')
    end
    
    it 'includes headers when need_response_header is true' do
      result = requester.send(:process_response, response, need_response_header: true)
      expect(result).to include('headers')
      expect(result['headers']).to include('Content-Type' => 'application/json')
    end
    
    it 'handles non-JSON responses' do
      non_json_response = instance_double(Faraday::Response, status: 200, body: 'Plain text', headers: {})
      result = requester.send(:process_response, non_json_response)
      expect(result).to include('status' => 200, 'body' => 'Plain text')
    end
  end

  describe '#object_present? and #object_blank?' do
    it 'correctly checks if object is present' do
      expect(requester.send(:object_present?, {})).to be false
      expect(requester.send(:object_present?, nil)).to be false
      expect(requester.send(:object_present?, '')).to be false
      expect(requester.send(:object_present?, 'test')).to be true
      expect(requester.send(:object_present?, {a: 1})).to be true
    end
  end

  # this testing need to view the request log for validation.
  describe 'test sort_params is vaild for faraday 2.0' do

    # INFO -- : request: GET http://example.com/test?param2=value2&param1=value1
    # INFO -- : request: User-Agent: "Faraday v2.13.1"
    # NFO -- : response: Status 200
    # INFO -- : response:
    it 'uses sort_params false for query parameters' do
      stub_request(:get, "http://example.com/test?param1=value1&param2=value2")
        .to_return(status: 200, body: '{"result": "success"}')
        
      result = requester.normal_send(:get, '/test', {param2: 'value2', param1: 'value1'}, sort_params: false)
      expect(result).to include('status' => 200, 'result' => 'success')
    end

    # INFO -- : request: GET http://example.com/test?param1=value1&param2=value2
    # INFO -- : request: User-Agent: "Faraday v2.13.1"
    # INFO -- : response: Status 200
    # INFO -- : response:
    it 'uses sort_params true for query parameters' do
      stub_request(:get, "http://example.com/test?param1=value1&param2=value2")
        .to_return(status: 200, body: '{"result": "success"}')
        
      result = requester.normal_send(:get, '/test', {param2: 'value2', param1: 'value1'}, sort_params: true)
      expect(result).to include('status' => 200, 'result' => 'success')
    end

    # INFO -- : request: GET http://example.com/test
    # INFO -- : request: User-Agent: "test_agent"
    # INFO -- : response: Status 200
    # INFO -- : response:
    it 'overrides User-Agent for specific request' do
      stub_request(:get, "http://example.com/test")
        .to_return(status: 200, body: '{"result": "success"}')

      result = requester_with_overide_user_agent.normal_send(:get, '/test')
      expect(result).to include('status' => 200, 'result' => 'success')
    end
  end
end