#
# File::      test_AllProcessors.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Programmatic tests run against all processors
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/SiteFuelRuntime'
require 'sitefuel/processors/AbstractStringBasedProcessor'

include SiteFuel

class TestAllProcessors < Test::Unit::TestCase

  def setup
    SiteFuelRuntime.load_processors
    @processors = SiteFuelRuntime.
            find_processors.
            delete_if do |proc|
              proc.to_s =~ /.*Test.*Processor/
            end

    @string_processors = Processor::AbstractStringBasedProcessor.
            find_processors.
            delete_if do |proc|
              proc.to_s =~ /.*Test.*Processor/
            end
  end

  # ensure that every filter in every filter set is known
  def test_filter_sets
    @processors.each do |proc|
      proc.filtersets.each do |filterset|
        proc.filters_in_filterset(filterset).each do |filter|
          assert(
            proc.filter?(filter),
            'Filter %s in filterset %s isn\'t known for %s' %
            [filter, filterset, proc]
          )
        end
      end
    end
  end

  # test that every processor has a default filterset
  def test_default_filter_sets
    @processors.each do |proc|
      assert proc.filterset?(proc.default_filterset), 'Default filterset %s for %s isn\'t known'%[proc.default_filterset, proc]
    end
  end

  # test that every string based processor's filters can handle the empty string
  def test_string_based_empty_string
    @string_processors.each do |proc|
      proc.filters.each do |filter|
        assert_nothing_raised { proc.filter_string(filter, '') }
      end
    end
  end
end