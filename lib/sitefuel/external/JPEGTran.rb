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

    require 'sitefuel/external/AbstractExternalProgram'

    class JPEGTran < AbstractExternalProgram

      def self.program_name
        'jpegtran'
      end

      # the versioning scheme for jpegtran is a little weir and not all
      # versions of jpegtran actually give a version number. So the best
      # we can do is check if the program exists and hope for the best.
      def self.compatible_versions
        ['6']
      end

      # since jpegtran by default writes jpeg files to stdout it's
      # a little obsessed about writing everything that isn't a jpeg
      # to stderr.
      #
      # this is to circumvent that.
      def self.capture_stderr
        true
      end

      # if the program exists... hope for the best.
      def self.test_version_number(compatible, version_number)
        true
      end

      # this rarely actually gives the option...
      def self.option_version
        '--help'
      end

      option :copy, '-copy ${value}', 'none'
      option :optimize, '-optimize'
      option :perfect, '-perfect'

      option :input, '${value}'
      option :output, '-outfile ${value}'


      def self.compress_losslessly(in_file, out_file)
        self.execute :copy,
                     :optimize,
                     :perfect,
                     :input, in_file,
                     :output, out_file
      end

    end

  end
end
