# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ansible_doc_generator/version'

Gem::Specification.new do |spec|
  spec.name          = 'ansible_doc_generator'
  spec.version       = AnsibleDocGenerator::VERSION
  spec.authors       = ['Víctor Martín', 'Fernando Blat']
  spec.email         = ['victor@populate.tools', 'fernando@populate.tools']

  spec.summary       = 'Document Ansible roles'
  spec.description   = "CLI for generating documentation of Ansible roles \
                        based on a markup language in their comments"
  spec.homepage      = 'https://github.com/PopulateTools/ansible-doc-generator'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = ['ansible-doc-generator']
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.7.0'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.59.2'
end
