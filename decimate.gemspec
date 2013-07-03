# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'decimate/version'

Gem::Specification.new do |spec|
  spec.name          = "decimate"
  spec.version       = Decimate::VERSION
  spec.authors       = ["Justin Wiley"]
  spec.email         = ["justin.wiley+decimate@gmail.com"]
  spec.description   = %q{Discipline your file-system by selectively securely deleting some of it's precious files or directories.}
  spec.summary       = %q{Notable features:

 - Endeavors to prevent you from accidentally rm -rfing your root dir
 - Uses shred utility to securely delete files, before removing
 - Allows additional sanity checking of paths}
  spec.homepage      = ""
  spec.license       = "GPLV3"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rspec"
end
