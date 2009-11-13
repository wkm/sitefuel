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
# Deploy a site from SVN:
# <pre>sitefuel deploy svn+ssh://sitefuel.org/svn/tags/21 /var/www/</pre>
#
#

module SiteFuel

require 'processors/htmlprocessor.rb'
require 'processors/cssprocessor.rb'

html = Processor::HTMLProcessor::process('../tests/simplehtml/index.html')
html.stripwhitespace
p html.generate

css = Processor::CSSProcessor::process('../tests/simplehtml/style.css')
css.compact
p css.generate

end