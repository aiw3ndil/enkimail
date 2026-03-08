# frozen_string_literal: true

require_relative "lib/enkimail/version"

Gem::Specification.new do |spec|
  spec.name = "enkimail"
  spec.version = Enkimail::VERSION
  spec.authors = ["Albert Oliva"]
  spec.email = ["albert.oliva@gmail.com"]

  spec.summary = "Enkimail delivery method for ActionMailer"
  spec.description = "Integrate Rails with Enkimail API to send emails seamlessly."
  spec.homepage = "https://github.com/aiw3ndil/enkimail"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/aiw3ndil/enkimail"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
  spec.add_dependency "mail", ">= 2.8"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
