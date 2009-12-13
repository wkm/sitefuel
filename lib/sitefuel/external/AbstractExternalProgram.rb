#
# File::      AbstractExternalProgram.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# An abstraction around calling an external program.
#
# TODO: make this less dependent on the OS behaving like Linux/OS X.
# TODO: the general API here is still far from thought out.
#

module SiteFuel
  module External

    require 'sitefuel/SiteFuelLogger'

    # raised when an external program can't be found
    class ProgramNotFound < StandardError
      attr_reader :program_name
      def initialize(program_name)
        @program_name = program_name
      end
    end

    class VersionNotFound < StandardError
      attr_reader :program_name, :compatible_version, :actual_version
      def initialize(program_name, compatible_version, actual_version)
        @program_name = program_name
        @compatible_version = compatible_version
        @actual_version = actual_version
      end

      def to_s
        'Compatible versions of program %s are %s. Found version %s' %
        [program_name, compatible_version, actual_version]
      end
    end

    class UnallowedOptionName < StandardError
      attr_reader :program, :option_name, :excluded_names
      def initialize(program, option_name, excluded_names)
        @program = program
        @option_name = option_name
        @excluded_names = excluded_names
      end

      def to_s
        'Program %s declares option %s which has one of the illegal option names: %s' %
        [program, option_name, excluded_names]
      end
    end

    class MalformedOptions < StandardError
      attr_reader :program, :options
      def initialize(program, options)
        @program = program
        @options = options
      end

      def to_s
        'Program %s called with a malformed options pattern: %s' %
        [program, options.join(' ')]
      end
    end






    
    # lightweight abstraction around a program external to Ruby. The class
    # is designed to make it easy to use an external program in a batch
    # fashion. Note that the abstraction does not well support interacting
    # back and forth with external programs.
    class AbstractExternalProgram

      include SiteFuel::Logging

      VERSION_SEPARATOR = '.'

      # cache of whether compatible versions exist
      @@compatible_versions = {}

      # todo: do we actually use these??
      @@program_binary = {}
      @@program_options = {}

      @@option_struct = Struct.new('ExternalProgramOption', 'name', 'template', 'default')

      # classes which implement AbstractExternalProgram need to define
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
          @@program_binary[self] = binary
          binary
        end
      end

      # Similar to Kernel#exec, but returns a string of the output
      def self.capture_output(command, *args)
        cli = command + ' ' + args.join(' ')
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

      # gives a condition on the compatible versions. A version is considered compatible
      # if it's greater than the given version. Eventually we'll probably need a way to
      # give a version range and allow excluding particular versions.
      def self.compatible_versions
        '> 0.0.0'
      end

      # gives true if a binary with a compatible version exists
      def self.compatible_version?
        compatible_version_number?(program_version)
      end

      # gives true if the given version is newer.
      # TODO should be renamed to #version_newer?
      def self.version_less?(lhs, rhs)
        return true if lhs == rhs

        # split into separate version chunks
        lhs = lhs.split(VERSION_SEPARATOR)
        rhs = rhs.split(VERSION_SEPARATOR)

        # if lhs is shorter than the rhs must be greater than or equal to the
        # lhs; but if the lhs is *longer* than the rhs must be greater than the
        # lhs.
        if lhs.length > rhs.length
          lhs = lhs[0...rhs.length]
          method = :<
        else
          method = :<=
          rhs = rhs[0...lhs.length]
        end

        # now compare
        lhs.join(VERSION_SEPARATOR).send(method, rhs.join(VERSION_SEPARATOR))
      end

      # tests a version number against a list of compatible version specifications
      # should be made into a Version class. We could also expand the Gem::Version
      # class and use that....
      def self.test_version_number(compatible, version_number)
        # ensure we're dealing with an array
        version_scheme = compatible
        if not version_scheme.kind_of? Array
          version_scheme = [version_scheme]
        end

        version_scheme.each do |ver|
          case ver[0..0]
            when '>'
              return version_less?(ver[1..-1].strip, version_number)
            when '<'
              return !version_less?(ver[1..-1].strip, version_number)
            else
              # ignore this version spec
          end
        end

        return false
      end

      # gives true if a given version number is compatible
      def self.compatible_version_number?(version_number)
        self.test_version_number(compatible_versions, version_number)
      end

      # raises the ProgramNotFound error if the progam can't be found
      # See also AbstractExternalProgram.verify_compatible_version
      def self.verify_program_exists
        if @@program_exists[self] == nil
          @@program_exists[self] = program_found?
        end
        
        if @@program_exists[self] == true
          return true
        else
          raise ProgramNotFound(self)
        end
      end

      
      # raises the ProgramNotFound error if the program can't be found
      # raises the VersionNotFound error if a compatible version isn't found.
      # the verification is cached using a class variable so the verification
      # only actually happens the first time.
      #
      # Because of the caching this function is generally very fast and should
      # be called by every method that actually will execute the program.
      def self.verify_compatible_version
        verify_program_exists
      
        if @@compatible_versions[self] == nil
          @@compatible_versions[self] = compatible_version?
        end

        if @@compatible_versions[self] == true
          return true
        else
          raise VersionNotFound.new(self, self.compatible_versions, self.program_version)
        end
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

      # calls an option
      def self.call_option(option_name)
        method_name = "option_"+option_name.to_s
        self.send(method_name.to_sym)
      end

      # gives the listing of declared options for the program
      def self.options
        names = methods
        names = names.delete_if { |method| not method =~ /^option_.*$/ }
        names.sort!

        names = names.map { |option_name| option_name.sub(/^option_(.*)$/, '\1').to_sym }
        names - excluded_option_names
      end

      # controls what happens with the output from the program
      # =capture=:: output is captured into a string and returned from #execute
      # =forward=:: output is forwarded to the terminal as normal
      def self.output_handling
        :capture
      end

      # list of excluded option names
      def self.excluded_option_names
        [:default, :template]
      end

      # tests whether a given option name is allowed
      def self.allowed_option_name?(name)
        not excluded_option_names.include?(name.to_sym)
      end

      # gives the default value for an option
      def self.option_default(option_name)
        self.call_option(option_name).default
      end

      # gives the template for an option
      def self.option_template(option_name)
        self.call_option(option_name).template
      end

      def self.option?(name)
        self.options.include?(name)
      end

      # declares an option for this program
      def self.option(name, string = nil, default = nil)
        unless name.kind_of? String
          name = name.to_s
        end

        unless allowed_option_name?(name)
          raise UnallowedOptionName.new(self, name, excluded_option_names)
        end


        # give a method for the option
        method_name = "option_"+name
        struct = @@option_struct.new(name, string, default)
        create_child_class_method(method_name.to_sym) { struct }

        # if the string contains ${value} it's settable, so add a
        # option_<name>= method
        if string.count("${value}") > 0
          method_name = "option_"+name+"="
#          create_child_class_method(method_name.to_sym) { }
        end
      end

      # allow the super class to programmatically create class methods
      # in child classes. This isn't a hack. Really. ;-) 
      def self.create_child_class_method(method_name, &block)
        self.class.send(:define_method, method_name, block)
      end

      # organizes a list of options into a ragged array of arrays
      #
      #  organize_options(:setflag, :paramsetting, 'val1', 'val2')
      #  # =>[[:setflag], [:paramsetting, 'val1', 'val2']]
      def self.organize_options(*options)
        organized = []
        i = 0

        while i < options.length
          # if we see a symbol are at a new option
          if options[i].kind_of? Symbol
            option_row = [options[i]]
            organized << option_row

            j = i+1
            while j < options.length
              case options[j]
                when String
                  # adds this value
                  option_row << options[j]
                  j += 1
                
                when Symbol
                  # the zoom below will cause this spot to get looked at
                  break
                
                else
                  # the zoom below will force us to look at this spot again
                  # and bail
                  break
              end
            end

            # zoom i ahead to this spot
            i = j
          else
            raise MalformedOptions.new(self, options)
          end
        end

        return organized
      end



      # creates and executes an instance of this external program by taking
      # a list of parameters and their values
      #
      #  self.execute :setflag,                       # set a flag
      #               :paramsetting, "param value",   # pass a single value
      #               :paramsetting2, "val1", "val2"  # pass multiple values
      def self.execute(*options)
        instance = self.new
        organized = organize_options(*options)

        organized.each do |opt|
          instance.add_option(opt)
        end

        instance.execute
      end




      
      #
      # INSTANCE METHODS
      #

      attr_reader :options

      def initialize
        # check that a compatible version exists
        self.class.verify_compatible_version

        self.logger = SiteFuelLogger.instance
        @options = []
      end

      # adds an option to be passed to this instance
      def add_option(option_row)
        case option_row
          when Array
            @options << option_row
        end
      end


      def option_template(name)
        self.class.option_template(name)
      end

      # executes the given AbstractExternalProgram instance
      def execute
        self.class.verify_compatible_version

        exec_string = self.class.program_binary.clone
        @options.each do |option_row|
          case option_row.length
            when 1
              option_string = option_template(option_row.first)

            when 2
              option_string = option_template(option_row.first).gsub('${value}', option_row[1])

            else
              option_string = ''
          end
          exec_string << ' ' << option_string
        end

        info 'Executing: '+exec_string

        case self.class.output_handling
          when :capture
            self.class.capture_output(exec_string)

          when :forward
            exec(exec_string)
        end
      end

    end
  end
end
