Gem::Specification.new do |s|
  s.name        = 'json_requester'
  s.version     = '0.1.0'
  s.platform    = Gem::Platform::RUBY
  s.summary     = 'Basic Wrapper of Faraday'
  s.description = 'wrapper of faraday'
  s.authors     = ['JiaRou Lee']
  s.email       = 'laura34963@kdanmobile.com'
  s.homepage    = 'https://github.com/laura34963/json_requester'
  s.license     = 'MIT'

  s.files            = `git ls-files -- lib/*`.split("\n")
  s.extra_rdoc_files = [ 'README.md' ]
  s.rdoc_options     = ['--charset=UTF-8']
  s.require_path     = "lib"

  s.required_ruby_version = '>= 2.5.1'
end