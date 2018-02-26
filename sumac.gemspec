Gem::Specification.new do |s|
  s.name        = 'sumac'
  s.version     = '0.0.0'
  s.date        = '2018-02-25'
  s.summary     = "Object based communication protocol."
  s.description = "Eases implementation of computer to computer communication by enabling programs to pass objects between each other."
  s.authors     = ["Rob Fors"]
  s.email       = 'mail@robfors.com'  
  s.files       = Dir.glob("{lib,test}/**/*") + %w(LICENSE README.md)
  s.homepage    = 'https://github.com/robfors/ruby-sumac'
  s.license     = 'Apache-2.0'
  s.add_runtime_dependency 'emittable', '=0.0.1'
  s.add_runtime_dependency 'quack_concurrency', '=0.0.1'
  s.add_runtime_dependency 'queued_state_machine', '=0.0.1'
end
