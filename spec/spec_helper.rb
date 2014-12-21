require "simplecov"
require "coveralls"
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]
SimpleCov.start do
  add_filter "/spec/"
  add_filter 'vendor' # Don't include vendored stuff
end

require "lita-campfire"
require "lita/rspec"
Lita.version_3_compatibility_mode = false

include Lita::Adapters
