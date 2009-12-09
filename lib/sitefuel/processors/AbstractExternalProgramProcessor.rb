#
# File::      AbstractExternalProgramProcessor.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

module SiteFuel
  module Processor

    require 'sitefuel/processors/AbstractProcessor'

    
    # Defines an abstract processor that offloads the work onto an external program.
    # These are typically processors for handling binary files (eg. images)
    #
    # These processors spend a bunch of time ensuring the external program exists
    # and of the appropriate version; each filter then will typically setup more
    # parameters to pass to the program.
    class AbstractExternalProgramProcessor < AbstractProcessor

      def self.processor_type
        'External'
      end

      def self.process_file(filename, config = {})
        # TODO: implement... ;)
      end
      
    end

  end
end