Gem::Specification.new do |spec|
  spec.name          = "lita-campfire"
  spec.version       = "0.1.3"
  spec.authors       = ["Jose Luis Salas", "Zac Stewart"]
  spec.email         = ["josacar@gmail.com", "zgstewart@gmail.com"]
  spec.description   = %q{A Campfire adapter for Lita.}
  spec.summary       = %q{A Campfire adapter for the Lita chat robot.}
  spec.homepage      = "https://github.com/josacar/lita-campfire"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  spec.metadata      = { "lita_plugin_type" => "adapter" }

  spec.add_runtime_dependency "lita", "~> 2.7.0"
  spec.add_runtime_dependency "tinder", "~> 1.9.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0.0.beta1"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end