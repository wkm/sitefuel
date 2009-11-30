require 'rubygems'
#Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name       = 'sitefuel'
  s.version    = '0.1.0'
  s.author     = 'wkm'
  s.email      = 'wkm@sitefuel.org'
  s.homepage   = 'http://sitefuel.org'
  s.platform   = Gem::Platform::RUBY
  s.summary    = 'A lightweight Ruby framework for processing, optimizing, and deploying websites'
  s.files      = FileList["{bin,test,lib,docs}/**/*"].exclude("rdoc").to_a
  s.require_path     = 'lib'
  s.test_file        = 'test/ts_gem.rb'
  s.has_rdoc         = true
  s.extra_rdoc_files = ['README']
  
  # Gem dependencies
  
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
