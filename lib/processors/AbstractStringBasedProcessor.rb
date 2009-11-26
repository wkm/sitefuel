#
# File::      AbstractStringBasedProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Defines an abstract processor that runs by loading an entire file into
# memory as a string. Since most files we're looking at are very small
# anyway (seeing as they're intended to be served millions of times) this
# is usually fine.
#

require 'processors/AbstractProcessor'

class AbstractStringBasedProcessor < AbstractProcessor
  
end