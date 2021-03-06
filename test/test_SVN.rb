#
# File::      test_SVN.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the SVN version system abstraction
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'sitefuel/external/SVN'

include SiteFuel::External

# just for testing we capture stderr since the negative tests
# get rather verbose
class SVN
  def self.capture_stderr
    true
  end
end

class TestSVN < Test::Unit::TestCase
  TEST_REPOSITORIES = File.expand_path(File.join(File.dirname(__FILE__), 'repositories', 'svn'))

  def test_checkout
    dir = SVN.export 'file://'+File.join(TEST_REPOSITORIES, 'testrepo1')
    files = Dir[File.join(dir, "**/*")].map do |f|
      File.basename(f)
    end
    
    assert files.include? 'style.css'
    assert files.include? 'deployment.yml'
    assert files.include? 'index.html'


    # now let's test a checkout where the repo doesn't exist...
    assert_raises(ProgramExitedWithFailure) do
      SVN.export 'file://'+File.join(TEST_REPOSITORIES, 'nonexistentrepo')
    end
  end
end