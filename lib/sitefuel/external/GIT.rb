#
# File::      GIT.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Wrapper around the git version control system.
#

module SiteFuel
  module External

    require 'sitefuel/external/AbstractExternalProgram'

    # defines a wrapper around the Git version control system
    # this wrapper is designed to only handle 
    class GIT < AbstractExternalProgram

      def self.program_name
        'git'
      end

      # this would probably work with 
      def self.compatible_versions
        '> 1.4'
      end

      # creates a new repository from an existing git repository
      option :clone, 'clone'

      # sets the source from which to read repository data
      option :source, '${value}'

      # specify a depth for a shallow clone
      option :depth, '--depth ${value}', 1

      # specifies an output directory for git
      option :output, '${value}'

      # creates a shallow clone of an existing repository
      def self.shallow_clone(source, directory = nil, depth=1)
        if directory == nil
          directory = create_tmp_directory('git')
        end

        execute :clone,
                :depth, depth,
                :source, source,
                :output, directory

        directory
      end
      
    end
  end
end