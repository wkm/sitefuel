#
# File::      AbstractExternalProgram.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# An abstraction around calling an external program.
#
# TODO: make this less dependent on the OS behaving like Linux/OS X.
# TODO: the general API here is still far from thought out.
#

module SiteFuel
  module External

    require 'sitefuel/extensions/DynamicClassMethods'
    require 'sitefuel/SiteFuelLogger'

    require 'tmpdir'
    require 'sha1'

    # raised when an external program can't be found
    class ProgramNotFound < StandardError
      attr_reader :program_name
      def initialize(program_name)
        @program_name = program_name
      end
    end


    
    # raised when the program appears to be found but it's version is not
    # compatible
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



    # raised when an option is given that isn't known
    class UnknownOption < StandardError
      attr_reader :program, :option_name
      def initialize(program, option_name)
        @program = program
        @option_name = option_name
      end

      def to_s
        'Program %s doesn\'t have option %s' %
        [program, option_name]
      end
    end



    # because of the AbstractExternalProgram's API design there are certain
    # option names that are disallowed (see
    # AbstractExternalProgram#excluded_option_names)
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



    # AbstractExternalProgram#execute and friends have a somewhat strange syntax
    # for accepting options and flags. This exception is raised when the syntax
    # is malformed.
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



    # raised when a default is specified for an option without a value slot in
    # the option template
    class NoOptionValueSlot < StandardError
      attr_reader :program, :option_name
      def initialize(program, option_name)
        @program = program
        @option_name = option_name
      end

      def to_s
        'Program %s has default value but no option slot for option %s' %
        [program, option_name]
      end
    end



    # raised when a option requires a value (because no default is specified)
    # but none is given
    class NoValueForOption < StandardError
      attr_reader :program, :option_name
      def initialize(program, option_name)
        @program = program
        @option_name = option_name
      end

      def to_s
        'Program %s option %s requires a value, but no value was specified' %
        [program, option_name]
      end
    end






    
    # lightweight abstraction around a program external to Ruby. The class
    # is designed to make it easy to use an external program in a batch
    # fashion. Note that the abstraction does not well support interacting
    # back and forth with external programs.
    class AbstractExternalProgram

      include SiteFuel::Logging

      VERSION_SEPARATOR = '.'

      # cache of whether compatible versions of programs exist
      @@compatible_versions = {}

      # cache of whether the actual programs that are abstracted exist
      @@program_exists = {}

      #
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


        # if we want to capture stderr we need to redirect to stdout
        if capture_stderr
          cli << ' 2>&1'
        end

        output_string = ""
        IO.popen(cli, 'r') do |io|
          output_string = io.read.chop
        end
        output_string
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
      # TODO this should be replaced by a proper version handling library (eg.
      # versionometry (sp?))
      def self.version_older? (lhs, rhs)
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
              return version_older?(ver[1..-1].strip, version_number)
            when '<'
              return !version_older?(ver[1..-1].strip, version_number)
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


      # raises the ProgramNotFound error if the program can't be found
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


      # option for giving the version of the program
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
        ensure_valid_option(option_name)
        self.call_option(option_name).default
      end


      # gives the template for an option
      def self.option_template(option_name)
        ensure_valid_option(option_name)
        self.call_option(option_name).template
      end


      # gives true if given a known option
      def self.option?(name)
        self.options.include?(name)
      end


      # raises UnknownOption error if the given option isn't valid
      def self.ensure_valid_option(name)
        if not option?(name)
          raise UnknownOption.new(self, name)
        end
      end


      # declares an option for this program
      def self.option(name, template = nil, default = nil)
        unless name.kind_of? String
          name = name.to_s
        end

        unless allowed_option_name?(name)
          raise UnallowedOptionName.new(self, name, excluded_option_names)
        end

        # if a default is given but the template has no value slot...
        if default != nil and not template.include?('${value}')
          raise NoOptionValueSlot.new(self, name)
        end


        # give a method for the option
        method_name = "option_"+name
        struct = @@option_struct.new(name, template, default)
        define_class_method(method_name.to_sym) { struct }
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
                when String, Fixnum, Float
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


      # creates a random string by hashing the current time into hexadecimal
      def self.random_string(length=12)
        Digest::SHA1.hexdigest(Time.now.to_f.to_s)[0, length]
      end


      # creates a temporary directory for sitefuel
      def self.create_tmp_directory(keyword)
        dir_name = File.join(Dir.tmpdir, "sitefuel-#{keyword}-#{random_string}")
        Dir.mkdir(dir_name)

        dir_name
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

      
      # ensures the option specification makes sense
      def ensure_option_validity(option_row)
        name = option_row.first
        if requires_value?(name) and option_row.length < 2
          raise NoValueForOption.new(self.class, name) 
        end

        true
      end


      # gives true if the given option is valid
      def valid_option?(option_row)
        ensure_option_validity(option_row)
        return true
      rescue
        return false
      end


      # adds an option to be passed to this instance
      def add_option(option_row)
        ensure_option_validity(option_row)

        case option_row
          when Array
            @options << option_row
        end
      end


      # gives the template for an option
      def option_template(name)
        self.class.option_template(name)
      end


      # generally we don't want to capture stderr since it helps users
      # with finding out why things don't work. In certain cases we do
      # need to capture it, however.
      def self.capture_stderr
        false
      end

        
      # applies a given value into an option template
      def apply_value(option_template, value)
        option_template.gsub('${value}', value.to_s)
      end
        

      # returns true if a given option takes a value
      # TODO this should be precomputed
      def takes_value? (name)
        option_template(name).include?('${value}')
      end


      # gives true if an option has a default
      def has_default?(name)
        self.class.option_default(name) != nil
      end


      # gives true if an option takes a value but has no default
      def requires_value?(name)
        takes_value?(name) and not has_default?(name)
      end


      # builds the command line for a given program instance
      def build_command_line
        self.class.verify_compatible_version

        exec_string = self.class.program_binary.clone
        @options.each do |option_row|
          option_string = option_template(option_row.first)
          case option_row.length
            when 1
              if takes_value?(option_row.first)
                option_string = apply_value(option_string, self.class.option_default(option_row.first))
              end

            when 2
              option_string = apply_value(option_string, option_row[1])

            else
              option_string = ''
          end
          exec_string << ' ' << option_string
        end

        exec_string
      end
        

      # executes the given AbstractExternalProgram instance
      def execute
        exec_string = build_command_line

        info '    Executing: '+exec_string
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
