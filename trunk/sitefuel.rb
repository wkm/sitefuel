#!/usr/bin/ruby
#
# File::      sitefuel.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# === Introduction
# sitefuel is a lightweight ruby framework for deploying websites directly from
# version control. sitefuel includes support for compressing HTML and CSS as
# well as optimizing PNG graphics. Support is planned for SASS; compressing
# JavaScript; automatically creating sprites; and supporting more image formats.
# (and more!)
#
#
# === Examples
# Process an already deployed site:
# <pre>sitefuel process /var/www/</pre>
#
# Deploy a site from SVN:
# <pre>sitefuel deploy svn+ssh://sitefuel.org/svn/tags/21 /var/www/</pre>
#
# Specify a non-default deployment file:
# <pre>sitefuel process /var/www/ -c customdeployment.yml</pre>
#

module SiteFuel

  # add source/ to the load path
  $:.unshift File.join(File.dirname(__FILE__), "source")

  require 'SiteFuelRuntime.rb'

  runtime = SiteFuelRuntime.new
  runtime.run
end