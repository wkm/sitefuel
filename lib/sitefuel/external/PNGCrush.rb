#
# File::      PNGCrush.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Wrapper around the pngcrush program.
#
#

module SiteFuel
  module External


    # Defines a gentle wrapper around the pngcrush program. This wrapper is
    # specifically intended for use with the -reduce and -brute options.
    class PNGCrush < ExternalProgram

      def self.program_name
        'pngcrush'
      end

      # most likely earlier versions of pngcrush would work as well
      # but we've only ever tested it with 1.5.10
      def self.compatible_versions
        ['1.5']
      end

      # define options
      option :version, '-version'
      option :brute, '-brute'
      option :reduce, '-reduce'
      option :method, '-method ${value}', '115'
      option :input, '${value}'
      option :output, '${value}'
      

      # command line builder
      def self.command_line(options)
        [
          # first we put any normal options
          option_value(options),
          option_value(options, :output)

        ]
      end

    end

  end
end