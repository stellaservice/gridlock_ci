# frozen_string_literal: true

require_relative 'lib/gridlock_ci/version'

Gem::Specification.new do |spec|
  spec.name = 'gridlock_ci'
  spec.version = GridlockCi::VERSION
  spec.authors = ['Steven Goodstein']
  spec.email = ['sgoodstein@medallia.com']

  spec.summary = 'Connect with gridlock CI server for dynamic test splitting'
  # spec.description = "TODO: Write a longer description or delete this line."
  spec.homepage = 'https://github.com/stellaservice/gridlock_ci'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/stellaservice/gridlock_ci'
  # spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files`.split.reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'faraday', '~> 2.7'
  spec.add_dependency 'faraday-multipart', '~> 1.0'
  spec.add_dependency 'faraday-retry', '~> 2.2'
  spec.add_dependency 'rspec-core', '~> 3.12'
  spec.add_dependency 'rspec_junit_formatter', '~> 0.6'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
