#
# File::      test_GIT.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the Git version system abstraction
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'sitefuel/external/GIT'

include SiteFuel::External

class GIT
  def self.capture_stderr
    true
  end
end

class TestGIT < Test::Unit::TestCase
  TEST_REPOSITORIES = File.join(File.dirname(__FILE__), 'repositories', 'git')

  def test_checkout
    dir = GIT.shallow_clone(File.join(TEST_REPOSITORIES, 'few_files'))
    files = Dir[File.join(dir, "**/*")]
    files.collect! do |f|
      File.basename(f)
    end

    assert files.include? 'style.css'
    assert files.include? 'deployment.yml'
    assert files.include? 'index.html'

    assert_raises(ProgramExitedWithFailure) do
      GIT.shallow_clone File.join(TEST_REPOSITORIES, 'this_repo_no_exist')
    end
  end
end