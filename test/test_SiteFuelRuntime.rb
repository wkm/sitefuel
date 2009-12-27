#
# File::      test_SiteFuelRuntime.m
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the SiteFuelRuntime class.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'logger'

require 'sitefuel/SiteFuelRuntime'
require 'sitefuel/SiteFuelLogger'

require 'sitefuel/processors/AbstractProcessor'
require 'sitefuel/processors/HTMLProcessor'
require 'sitefuel/processors/CSSProcessor'
require 'sitefuel/processors/SASSProcessor'

include SiteFuel

class HTMLClasherTest < Processor::AbstractProcessor
  def self.file_patterns
    [".html"]
  end
end

class OtherProcessorA < Processor::AbstractProcessor; end
class OtherProcessorB < Processor::AbstractProcessor; end

class TestSiteFuelRuntime < Test::Unit::TestCase

  def setup
    @runtime = SiteFuelRuntime.new
  end

  def test_processor_picking
    assert_equal Processor::CSSProcessor, @runtime.choose_processor("foo.css")
    assert_equal Processor::HTMLProcessor, @runtime.choose_processor("foo.html")
    assert_equal Processor::HTMLProcessor, @runtime.choose_processor("FOO.HtM")

    assert_equal Processor::CSSProcessor, @runtime.choose_processor!("foo.css")
    assert_equal Processor::HTMLProcessor, @runtime.choose_processor!("foo.html")
    assert_equal Processor::HTMLProcessor, @runtime.choose_processor!("FOO.HtM")

    assert_nil @runtime.choose_processor("foo.xxxx")
    assert_nil @runtime.choose_processor("foocss")
    assert_nil @runtime.choose_processor("foohtml")

    assert_nil @runtime.choose_processor!("foo.xxxx")
    assert_nil @runtime.choose_processor!("foocss")
    assert_nil @runtime.choose_processor!("foohtml")
  end

  def test_processor_finding
    # test that we don't have the clasher, since it doesn't end with Processor
    assert !SiteFuelRuntime.find_processors.include?(HTMLClasherTest), 'HTMLClasherTest included'

    # test that we do have the basic processor test suite
    assert SiteFuelRuntime.find_processors.include?(Processor::HTMLProcessor)
    assert SiteFuelRuntime.find_processors.include?(Processor::CSSProcessor)
    assert SiteFuelRuntime.find_processors.include?(Processor::SASSProcessor)
  end

  def test_processor_clashing

    # test adding of a single processor
    original = @runtime.processors.clone
    @runtime.add_processor(HTMLClasherTest)
    assert_equal [HTMLClasherTest], @runtime.processors - original

    # test adding of an array of processors
    original = @runtime.processors.clone
    @runtime.add_processor([OtherProcessorA, OtherProcessorB])
    assert_equal [OtherProcessorA, OtherProcessorB], @runtime.processors - original
    
    assert_raise Processor::MultipleApplicableProcessors do
      @runtime.choose_processor("foo.html")
    end

    # test that SiteFuelLogger#choose_processor! doesn't throw
    # a message but does log a warning
    SiteFuelLogger.instance.level = Logger::UNKNOWN
    warnings = SiteFuelLogger.instance.warn_count
    assert_nothing_raised do
      @runtime.choose_processor!("foo.html")
    end
    assert_equal warnings+1, SiteFuelLogger.instance.warn_count

    assert_equal Processor::HTMLProcessor, @runtime.choose_processor("foo.htm")
  end


  def test_repository_system_classification
    assert_equal :git, @runtime.classify_repository_system('ssh://host/path/repo.git')
    assert_equal :git, @runtime.classify_repository_system('SSH://host/path/repo.git')
    assert_equal :git, @runtime.classify_repository_system('git://host/path/repo')
    assert_equal :git, @runtime.classify_repository_system('GIT://host/path/repo')
    assert_equal :git, @runtime.classify_repository_system('rsync://host/path/repo')
    assert_equal :git, @runtime.classify_repository_system('RSYNC://host/path/repo')


    assert_equal :svn, @runtime.classify_repository_system('svn+ssh://host/path/repo')
    assert_equal :svn, @runtime.classify_repository_system('SVN+ssh://host/path/repo')
    assert_equal :svn, @runtime.classify_repository_system('SVN://host/path/repo')
    assert_equal :svn, @runtime.classify_repository_system('svn://host/path/repo')

    # if it ends with .git, it's GIT
    assert_equal :git, @runtime.classify_repository_system('host/path/repo.git')
    assert_equal :git, @runtime.classify_repository_system('http://host/path/repo.git')
    assert_equal :git, @runtime.classify_repository_system('https://host/path/repo.git')

    # vanilla file system deployments
    assert_equal :filesystem, @runtime.classify_repository_system('./dir')
    assert_equal :filesystem, @runtime.classify_repository_system('/var/www/dir')
    assert_equal :filesystem, @runtime.classify_repository_system('dir/')
    assert_equal :filesystem, @runtime.classify_repository_system('../.dir/')
    assert_equal :filesystem, @runtime.classify_repository_system('../.dir/somehandle')

    # these shouldn't be classified, or are ambiguous
    assert_raises(UnknownVersioningSystem) do
      @runtime.classify_repository_system('http://host/repo')
    end
    assert_raises(UnknownVersioningSystem) do
      @runtime.classify_repository_system('https://host/repo')
    end

  end
end