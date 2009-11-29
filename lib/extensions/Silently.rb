#
# File::      Silently.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Implements a silently method for executing code without warnings; intended for
# wrapping around require statements
#



# this is sourced directly from
# http://vidyapsi.wordpress.com/category/ruby/#warnings

def silently(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil

  result = block.call

  $VERBOSE = warn_level
  result
end

# /end sourcing

