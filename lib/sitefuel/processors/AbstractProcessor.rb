#
# File::      AbstractProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Defines an AbstractProcessor class that gives the interface implemented by
# specific processors.
#

module SiteFuel
  module Processor

    require 'sitefuel/SiteFuelLogger'
    require 'sitefuel/processors/Configurable'

    # raised when a method isn't implemented by a child class.
    class NotImplemented < StandardError; end



    # raised when attempting to run a filter that doesn't exist
    class UnknownFilter < StandardError
      attr_reader :processor, :name

      def initialize(processor, name)
        @processor = processor
        @name = name
      end

      def to_s
        "'%s' called for processor '%s'" %
        [@name, @processor.class]
      end
    end



    class UnknownFilterset < StandardError
      attr_reader :processor, :name

      def initialize(processor, name)
        @processor = processor
        @name = name
      end

      def to_s
        "'%s' called for processor '%s'" %
        [@name, @processor.class]
      end
    end



    # raised when multiple processors trigger off of a single file
    class MultipleApplicableProcessors < StandardError
      attr_reader :filename, :processors, :chosen_processor

      def initialize(filename, processors, chosen_processor)
        @filename = filename
        @resource_processors = processors
        @chosen_processor = chosen_processor
      end

      def to_s
        "File '%s' triggered processors: %s. Using %s" %
        [@filename, @resource_processors.join(', '), @chosen_processor.class]
      end
    end



    # defines the base functions every processor must implement to
    # interface with the sitefuel architecture
    class AbstractProcessor

      include SiteFuel::Logging
      extend SiteFuel::ClassLogging

      include Configurable

      # setup an AbstractProcessor
      def initialize        
        self.logger = SiteFuelLogger.instance
        @execution_list = []
        @filters = []
      end


      # gives a list of processors that implement AbstractProcessor
      def self.find_processors
        procs = []
        ObjectSpace.each_object(Class) do |cls|
          if cls.ancestors.include?(self) and
             cls.to_s =~ /^.*Processor$/ and
             not cls.to_s =~ /^.*Abstract.*Processor$/
          then
            procs << cls
          end
        end

        procs
      end

      # gives the type of the processor, usually implemented
      # by the more specific abstract processors.
      def self.processor_type
        ''
      end


      #
      # PROCESSOR INFORMATION
      #

      # gives the canonical name of the resource
      attr_reader :resource_name

      # gives the original size of a resource before being processed
      attr_reader :original_size

      # gives the size of the resouce now that it's been processed
      attr_reader :processed_size

      # gives the display name for the processor
      def self.processor_name
        self.to_s.sub(/.*\b(.*)Processor/, '\1')
      end

      # gives the symbol of the processor; used when showing deployment
      # progress
      def processor_symbol
        'A'
      end

      
      # gives the file patterns that trigger the processor by default; this
      # behavior can be over-ridden by configuration files.
      #
      # * strings are assumed to be extensions and are tested for a literal match
      # * regexes are tested against the entire file name
      #
      def self.file_patterns
        []
      end

      # gives +true+ if filename matches one of #file_patterns.
      def self.file_pattern_match?(filename)
        file_patterns.map { |patt|
          case patt
          when String
              regex = Regexp.new("^.*"+Regexp.escape(patt)+"$", Regexp::IGNORECASE)
              return true if filename.match(regex) != nil
          when Regexp
              return true if filename.match(patt) != nil
          end
        }
        
        # if we got this far nothing matched
        return false
      end

      
      # uses #file_pattern_match? to decide if the file can be processed
      # eventually this may use other metrics (like mime types)
      def self.processes_file?(filename)
        file_pattern_match? filename
      end


      

      #
      # FILTER SET SUPPORT
      #

      # gives the default filterset used
      def self.default_filterset
        nil
      end

      # lists all filtersets for this processor
      def self.filtersets
        names = methods
        names = names.delete_if{|method| not method =~ /^filterset_.*$/ }
        names.sort!

        names.map { |filterset| filterset.sub(/^filterset_(.*)$/, '\1').to_sym }
      end

      # gives true if the given name is of a filter set for this processor
      def self.filterset?(name)
        respond_to?("filterset_" + name.to_s)
      end

      # the ignore filter set is used when configuring sitefuel to not process
      # certain kinds of files.
      def self.filterset_ignore
        []
      end

      # returns the filters in the given filter set, [] if no such filters
      # exist
      def self.filters_in_filterset(name)
        return [] unless self.filterset?(name)

        filter_list = self.send("filterset_" + name.to_s)
        
        if filter_list == nil
          return []
        else
          return filter_list
        end
      end

      # adds the filters in a filterset to the execution list
      def add_filterset(filterset)
        if self.class.filterset?(filterset)
          # extract the filters in the filterset and add them to the list
          filter_list = self.class.filters_in_filterset(filterset)
          filter_list.each do |filter|
            add_filter(filter)
          end
          @execution_list
        else
          raise UnknownFilterset.new(self, filterset)
        end
      end

      # evaluate a filterset
      def run_filterset(name)
        if self.class.filter_set?("filterset_" + name.to_s)
          self.send("filterset_" + name.to_s)
        else
          raise UnknownFilterset(self, name)
        end
      end


      #
      # FILTER SUPPORT
      #

      # lists all the filters implemented by a processor
      def self.filters
        names = instance_methods
        names = names.delete_if{ |method| not method =~ /^filter_.*$/ }
        names.sort!
        
        names.map { |filter_name| filter_name.sub(/^filter_(.*)$/, '\1').to_sym }
      end

      # gives true if the given filter is known for this processor class
      def self.filter?(name)
        filters.include?(name.to_sym)
      end

      # gives true if the given filter is known for this processor instance
      def filter?(filter)
        respond_to?("filter_" + filter.to_s)
      end

      # array of filters to run
      attr_reader :execution_list

      # adds a filter or array of filters to the execution list
      #
      #  add_filter(:minify)
      #  add_filter([:beautifytext, :minify])
      def add_filter(filter)
        case filter
        when Array
          filter.each do |f|
            add_filter f
          end
        when Symbol, String
          if filter?(filter)
            @execution_list << filter
          else
            raise UnknownFilter.new(self, filter)
          end
        end
      end

      # clears all filters from the execution list
      def clear_filters
        @execution_list = []
      end

      # drops a filter from the execution list
      def drop_filter(filter)
        @execution_list.delete(filter)
        @execution_list
      end

      # runs a particular filter
      def run_filter(name)
        if respond_to?("filter_" + name.to_s)
          self.send("filter_"+name.to_s)
        else
          raise UnknownFilter.new(self, name)
        end
      end


      # called in #execute _before_ running the execution list of filters; note
      # that #setup_filters is only called _once_ before all of the filters are
      # batch executed. It is not called before every filter executes.
      def setup_filters; end

      
      # called in #execute _after_ running the execution list of filters
      def finish_filters; end


      # runs all filters in the execution list
      def execute
        setup_filters
        @execution_list.uniq.each do |filter|
          info "    Running filter: #{filter}"
          run_filter(filter)
        end
        finish_filters
      rescue => exception
        error 'from %s:%s: %s' % [self.class, resource_name, exception]
      end


      # creates a file with the given name
      def create_file(base_file_tree)
        base_file_tree.get_file(resource_name)
      end


      # default save method. This will only create a file, the
      # more specific abstractions need to implement the actual method
      def save(base_file_tree)
        create_file(base_file_tree)
      end

    protected
      #
      # Configuration Support
      #

      def pre_configuration
        @filters_cleared = false
      end

      def post_configuration
        if !@filters_cleared and execution_list.empty?
          add_filterset(self.class.default_filterset)
        end
        @filters_cleared = true
      end


      # ensures the filters have been cleared during this
      # configuration phase. Preforms the #clear_filters if they haven't
      def ensure_cleared_filters
        if not @filters_cleared
          clear_filters
          @filters_cleared = true
        end
      end


      # sets the name for the resource that is being processed
      def configure_resource_name(value)
        @resource_name = value
      end


      # adds filters to this processor
      def configure_filters(*values)
        ensure_cleared_filters
        values.each { |v| add_filter(v) }
      end


      # adds filtersets to this processor
      def configure_filtersets(*values)
        ensure_cleared_filters
        values.each { |v| add_filterset(v) }
      end

      
      # gives write-access to children classes
      attr_writer :original_size
      attr_writer :processed_size
      attr_writer :resource_name
      
    end
  end
end
