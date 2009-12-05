#
# File::      ExternalProgram.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# An abstraction around calling an external program.
#
# TODO: make this less dependent on the OS behaving like Linux/OS X.
#

module SiteFuel
  module External

    # raised when an external program can't be found
    class ProgramNotFound < StandardError
      attr_reader :program_name
      def initialize(program_name)
        @program_name = program_name
      end
    end

    # lightweight abstraction around a program external to Ruby. The class
    # is designed to make it easy to use an external program in a batch
    # fashion. Note that the abstraction does not well support interacting
    # back and forth with external programs.
    class ExternalProgram

      @@program_binary = {}

      # classes which implement ExternalProgram need to define
      # a self.program_name method.

      # gives the location of the external program; uses the =which=
      # unix command
      def self.program_binary

        # give the cached version if possible
        cached = @@program_binary[self]
        return cached if cached

        # otherwise try to find it:
        binary = capture_output("which", program_name)
        if binary.empty?
          raise ProgramNotFound.new(program_name)
        else
          # ensure the binary is resolved with respect to the root path
          binary = File.expand_path(binary, capture_output('pwd'))
#          binary = '\"%s\"' % binary
          @@program_binary[self] = binary
          binary
        end
      end

      # Similar to Kernel#exec, but returns a string of the output
      def self.capture_output(command, *args)
        cli = command + ' ' + args.join(' ')
        #File.read(cli).chop
        IO.popen(cli, 'r').read.chop
      end

      # gives true if the program can be found.
      def self.program_found?
        program_binary
      rescue ProgramNotFound
        false
      else
        true
      end

      # gives a list of compatible versions
      def self.compatible_versions
        '> 0.0.0.'
      end

      # gives true if a binary with a compatible version exists
      def self.compatible_version?

      end

      # gives true if a given version number is compatible
      def self.compatible_version_number?(versionnumber)

      end

      # given the output of a program gives the version number or nil
      # if not available
      def self.extract_program_version(version_output)
        version_output[/(\d+\.\d+(\.\d+)?([a-zA-Z]+)?)/]
      end

      # gives the version of the program
      def self.option_version
        '--version'
      end

      # gets the version of a program
      def self.program_version
        extract_program_version(capture_output(program_binary, option_version))
      rescue ProgramNotFound
        return nil
      end

      # describes options for the program
      def self.options
        []
      end



      #
      # INSTANCE METHODS
      #
      def add_option()

      end

    end
  end
end