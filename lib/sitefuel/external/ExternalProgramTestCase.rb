#
# File::      ExternalProgramTestCase.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Lightweight utility that will effectively scrap
# the entire test case if the program being tested doesn't exist.
#

require 'test/unit'
require 'term/ansicolor'

module SiteFuel
  module External

    include Term::ANSIColor

    class Test::Unit::TestCase
      # exposes the private #define_method function to the world
      def self.publicly_define_method(name, &block)
        define_method(name, &block)
      end
    end

    module ExternalProgramTestCase 
      
      @@message_posted = {}

      def get_tested_class
        name = self.class.to_s.gsub(/^(.*?::)?Test(.*)$/, "\\2")
        
        # ensure the class exists
        cls = Kernel.const_get(name)
        
        return cls if cls != nil
        return nil
      end
      
      def initialize(*args)
        cls = get_tested_class
        unless cls == nil
          if cls.program_found?
            # amusing pun.
            super(*args)
          else
            if not @@message_posted[self.class]
              puts "Ignoring #{cls} unit tests. Program #{cls.program_name} not found.".bold
              @@message_posted[self.class] = true
            end
            
            # fun part. Over-ride every method beginning with test* so they are nops
            methods = self.methods
            methods.each do |name|
              if name =~ /^test.*$/
                self.class.publicly_define_method(name) {}
              end
            end

            super(*args)
          end
        end
      end
    end
  end
end

