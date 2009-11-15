#
# File::      environment.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Load all of the gems used by sitefuel and ensure their version.
#

module SiteFuel

  require 'rubygems'

  gem 'hpricot',   '~> 0.8'   # html parsing
  gem 'jsmin',     '~> 1.0'   # javascript minify
  gem 'cssmin',    '~> 1.0'   # css minify
  gem 'haml',      '~> 2.2'   # for HAML and SASS support

  $SiteFuelVersion = [0, 0, 1]
end
