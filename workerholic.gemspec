require File.expand_path('../lib/workerholic/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'workerholic'
  gem.version       = Workerholic::VERSION

  gem.authors       = ['Antoine Leclercq', 'Konstantin Minevskiy', 'Timmy Lee']
  gem.email         = ['antoine.leclercq.49@gmail.com', 'lmwinr@gmail.com', 'tim-lee92@outlook.com']
  gem.summary       = 'Background Job Processor'
  gem.description   = 'A Background Job Processor for Ruby applications'
  gem.homepage      = 'https://github.com/workerholic/workerholic'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.executables   = ['workerholic']
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.2.2'

  gem.add_dependency 'redis', '~> 3.3', '>= 3.3.3'
  gem.add_dependency 'connection_pool', '~> 2.2', '>= 2.2.0'
  gem.add_dependency 'sinatra'

  gem.add_development_dependency 'pry-byebug'
  gem.add_development_dependency 'rspec', '~> 3.6', '>= 3.6.0'
end
