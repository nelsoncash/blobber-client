# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "blobber_client/version"

Gem::Specification.new do |s|
  s.name        = "blobber-client"
  s.version     = BlobberClient::VERSION
  s.authors     = ["Craig Ludington" "Chase Yeung"]
  s.email       = ["craig.ludington@alpheus.me"]
  s.homepage    = "https://github.com/craig-ludington/blobber-client.git"
  s.summary     = "Client library for interacting with Blobber."
  s.description = %q{Client library for interacting with Blobber. Requires a running instance of Blobber (localhost is fine).  See https://github.com/craig-ludington/blobber}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rest-client"

  s.add_development_dependency "bundler_geminabox"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "webmock"
end
