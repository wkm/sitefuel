#
# File::      AbstractExternalProgramProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Defines an abstract processor that offloads the work onto an external program.
# These are typically processors for handling binary files (eg. images)
#
# These processors spend a bunch of time ensuring the external program exists
# and of the appropriate version; each filter then will typically setup more
# parameters to pass to the program.
#

module SiteFuel
  module Processor

    require 'processors/AbstractProcessor'

    class AbstractExternalProgramProcessor < AbstractProcessor
      
    end

  end
end