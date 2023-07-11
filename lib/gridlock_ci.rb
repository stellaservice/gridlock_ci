# frozen_string_literal: true

require 'rspec/core'
require 'rspec_junit_formatter'
require 'json'
require 'faraday'

require_relative 'gridlock_ci/version'
require_relative 'gridlock_ci/client'
require_relative 'gridlock_ci/junit_output'
require_relative 'gridlock_ci/runner'

module GridlockCi
end
