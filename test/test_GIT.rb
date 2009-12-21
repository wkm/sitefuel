#
# File::      test_GIT.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Unit tests for the Git abstraction
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'sitefuel/external/GIT'

include SiteFuel::External

class TestGIT < Test::Unit::TestCase
  TEST_REPOSITORIES = File.join(File.dirname(__FILE__), 'repositories', 'git')

  def test_checkout
    dir = GIT.shallow_clone(File.join(TEST_REPOSITORIES, 'few_files'))

    puts Dir[File.join(dir, "**/*")]
  end
end