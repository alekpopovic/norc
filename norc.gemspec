# frozen_string_literal: true

require_relative "lib/norc/version"

Gem::Specification.new do |spec|
  spec.name = "norc"
  spec.version = Norc::VERSION
  spec.authors = ["aleksandar-popovic"]
  spec.email = ["aleksandar.popovic@hotmail.com"]

  spec.summary = "Cron Job Scheduler with Redis Persistence"
  spec.description = "This scheduler is production-ready for basic use cases and can be extended with more sophisticated cron parsing, job priorities, or distributed execution capabilities."
  spec.homepage = "https://github.com/alekpopovic/norc"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/alekpopovic/norc"
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(["git", "ls-files", "-z"], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?("bin/", "test/", "spec/", "features/", ".git", ".github", "appveyor", "Gemfile")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency("logger")
  spec.add_dependency("redis")
end
