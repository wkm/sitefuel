#
# File::      SVN.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Wrapper around the SVN version control system.
#

module SiteFuel
  module External

    require 'sitefuel/external/AbstractExternalProgram'

    class SVN < AbstractExternalProgram

      def self.program_name
        'svn'
      end

      # again, earlier versions would probably work
      def self.compatible_versions
        '> 1.2'
      end
      

      option :source, '${value}'
      option :export, 'export'
      option :revision, '-r ${value}'
      option :output, '${value}'
      option :force, '--force'

      def self.export(source, output=nil, revision='HEAD')
        use_force = false

        if output == nil
          output = create_tmp_directory('svn')
          use_force = true
        end

        args = [:export,
                :revision, revision,
                :source, source,
                :output, output]

        if use_force
          args << :force
        end

        execute(*args)

        output
      end

    end
  end
end