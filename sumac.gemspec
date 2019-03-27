Gem::Specification.new do |s|
  s.name        = 'sumac'
  s.version     = '0.0.1'
  s.date        = '2019-03-27'
  s.summary     = "Object based communication protocol."
  s.description = "Eases implementation of computer to computer communication by enabling programs to pass objects between each other."
  s.authors     = ["Rob Fors"]
  s.email       = 'mail@robfors.com'  
  s.files       = Dir.glob("{lib,test}/**/*") + %w(LICENSE README.md)
  s.homepage    = 'https://github.com/robfors/ruby-sumac'
  s.license     = 'Apache-2.0'
  s.add_runtime_dependency 'quack_concurrency', '~>0.6'
end
