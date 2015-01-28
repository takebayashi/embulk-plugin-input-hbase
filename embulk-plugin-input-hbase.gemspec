Gem::Specification.new { |gem|
  gem.name = 'embulk-plugin-input-hbase'
  gem.version = '0.0.1'
  gem.summary = gem.description = %q{Embulk plugin for HBase input}
  gem.authors = 'Shun Takebayashi'
  gem.email = 'shun@takebayashi.asia'
  gem.license = 'Apache 2.0'
  gem.homepage = 'https://github.com/takebayashi/embulk-plugin-input-hbase'
  gem.files = Dir.glob('lib/**/*') + ['README.md']
  gem.test_files = gem.files.grep(/test/)
  gem.require_paths = ['lib']

  gem.add_dependency 'hbase-jruby'
  gem.add_development_dependency 'bundler', ['~> 1.0']
  gem.add_development_dependency 'rake', ['>= 0.9.2']
}
