# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "passenger_reaper/version"

Gem::Specification.new do |s|
  s.name        = "passenger_reaper"
  s.version     = PassengerReaper::VERSION
  s.authors     = ["Josh Hull"]
  s.email       = ["joshbuddy@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Gemification of https://gist.github.com/596401/db750535df61e679aad69e8d9c9750f8640a234f}
  s.description = %q{Gemification of https://gist.github.com/596401/db750535df61e679aad69e8d9c9750f8640a234f.}

  s.rubyforge_project = "passenger_reaper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_runtime_dependency "chronic"
  s.add_development_dependency "rspec", ">= 2.0.0"
end
