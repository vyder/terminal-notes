# frozen_string_literal: true
require_relative 'lib/terminal-notes/version'

Gem::Specification.new do |spec|
  spec.name    = 'terminal-notes'
  spec.version = TerminalNotes::VERSION
  spec.authors = ['Vidur Murali']
  spec.email   = ['vidur@monkeychai.com']

  spec.summary  = "Searchable notes in your terminal! What's not to like?"
  spec.homepage = 'https://github.com/vyder/terminal-notes'
  spec.license  = 'MIT'

  spec.files         = Dir['lib/**/*.rb'] + %w[README.md]
  spec.bindir        = 'bin'
  spec.executables   = 'terminal-notes'
  spec.require_paths = ['lib']

  spec.metadata = {
    "documentation_uri" => 'https://vyder.github.io/terminal-notes'
  }

  spec.add_runtime_dependency     'ffi-ncurses',    '~> 0.4.0'
  spec.add_runtime_dependency     'fuzzy_match',    '~> 2.1.0'

  spec.add_development_dependency 'rake',           '~> 13.0.1'
  spec.add_development_dependency 'rspec',          '~> 3.9.0'
  spec.add_development_dependency 'rubygems-tasks', '~> 0.2.5'
  spec.add_development_dependency 'simplecov',      '~> 0.19.0'
  spec.add_development_dependency 'yard',           '~> 0.9.25'
end
