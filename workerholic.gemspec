lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'workerholic'
  gem.version       = '0.01'
  gem.authors       = ['Antoine Leclercq', 'Konstantin Minevskiy', 'Timmy Lee']
  gem.email         = ['antoine.leclercq.49@gmail.com',
                       'lmwinr@gmail.com',
                       'tim-lee92@outlook.com']
  gem.description   = 'A background job engine for Ruby'
  gem.summary       = 'A background job engine'
  gem.homepage      = 'https://github.com/workerholic/workerholic'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ['lib']

  gem.add_dependency 'redis'
  gem.add_dependency 'pry-byebug'

  gem.add_development_dependency 'rspec'
end
