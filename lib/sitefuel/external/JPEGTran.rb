#
# File::      JPEGTran.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Wrapper around the jpegtran program.
#

module SiteFuel
  module External

    require 'sitefuel/external/ExternalProgram'

    class JPEGTran < ExternalProgram

      def self.program_name
        'jpegtran'
      end

      def self.compatible_versions
        ['6']
      end

      def self.extract_program_version(version_output)
        version_output[/\d[a-z]/]
      end

      option :copy, '-copy ${value}', 'none'
      option :optimize, '-optimize'
      option :perfect, '-perfect'

      option :input, '${value}'
      option :output, '${value}'


      def self.compress_losslessly(in_file, out_file)
        self.execute(:copy, :optimize, :perfect, :input => in_file, :output => out_file)
      end

    end

  end
end