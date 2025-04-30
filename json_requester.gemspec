Gem::Specification.new do |s|
  s.name        = 'json_requester'
  s.version     = File.read('./VERSION.md')
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Basic Wrapper of Faraday'
  s.description = 'wrapper of faraday'
  s.authors     = ['JiaRou Lee']
  s.email       = 'laura34963@kdanmobile.com'
  s.homepage    = 'https://github.com/kdan-mobile-software-ltd/json_requester'
  s.license     = 'MIT'
  s.metadata    = {
    "source_code_uri" => "https://github.com/kdan-mobile-software-ltd/json_requester",
    "changelog_uri" => "https://github.com/kdan-mobile-software-ltd/json_requester/blob/master/CHANGELOG.md"
  }

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.extra_rdoc_files = [ 'README.md' ]
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = "lib"

  s.required_ruby_version = '>= 3.0.0'
  s.add_runtime_dependency "faraday", "~> 2.0", ">= 2.0.1"
  s.add_runtime_dependency 'faraday-multipart', '~> 1.1.0'
  s.add_development_dependency 'pry', '~> 0.14.2'
  s.add_development_dependency "rspec", "~> 3.0"
  s.add_development_dependency "webmock", "~> 3.25", ">= 3.25.1"
end
