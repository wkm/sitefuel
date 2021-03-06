#
# File::      PNGCrush.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Wrapper around the pngcrush program.
#
#

module SiteFuel
  module External

    require 'sitefuel/external/AbstractExternalProgram'

    # Defines a gentle wrapper around the pngcrush program. This wrapper is
    # specifically intended for use with the -reduce and -brute options.
    class PNGCrush < AbstractExternalProgram

      def self.program_name
        'pngcrush'
      end

      # most likely earlier versions of pngcrush would work as well
      # but we've only ever tested it with 1.5.10
      def self.compatible_versions
        ['> 1.5']
      end

      # define options
      option :version, '-version'
      option :brute,   '-brute'
      option :reduce,  '-reduce'
      option :method,  '-method ${value}', '115'
      option :rem,     '-rem ${value}', 'alla'
      option :z,       '-z ${value}', '1'
      option :input,   '${value}'
      option :output,  '${value}'

      # uses -brute with PNGCrush to find the smallest file size, but at the
      # expense of taking quite a while to run.
      def self.brute(in_file, out_file)
        execute :brute,
                :reduce,
                :input, in_file,
                :output, out_file
      end

      # quick uses the default png crush configuration to smash up PNGs
      def self.quick(in_file, out_file)
        execute :input, in_file,
                :output, out_file
      end

      # strips out all data except the RGBA values (any copyrights, gamma, etc.)
      def self.chainsaw (in_file, out_file)
        execute :rem, 'alla',
                :reduce,
                :z, '1',
                :input, in_file,
                :output, out_file
      end

    end
  end
end