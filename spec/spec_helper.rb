# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'ansible_doc_generator'

RSpec.configure do |config|
  config.mock_with :rspec
  config.order = 'random'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
