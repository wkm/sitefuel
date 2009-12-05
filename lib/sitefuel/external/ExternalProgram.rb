#
# File::      ExternalProgram.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# An abstraction around calling an external program
#

module SiteFuel

  class ExternalProgram

    def self.program_binary

    end

    # gives the name of the external program
    def self.program_name
      self.program_binary
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
    def self.get_program_version(version_output)
      versions = version_output.scan(/\d+\.\d+(\.\d+)/)
      if versions.length == 0
        return nil
      else
        return versions[0]
      end
    end

    # gives the version of the program
    def self.option_version
      '--version'
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