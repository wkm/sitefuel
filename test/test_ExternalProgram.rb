#
# File::         test_ExternalProgram.rb
# Author::       wkm
# Copyright::    2009
# License::      GPL
#
# Unit tests for the ExternalProgram wrapper.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'

require 'sitefuel/external/ExternalProgram'

include SiteFuel

# a wrapper around a generic program
class BashProgram < External::ExternalProgram
  def self.program_name
    'bash'
  end
end

# a wrapper around a program which hopefully doesn't exist ;)
class BadProgram < External::ExternalProgram
  def self.program_name
    'foo183127cowsaydog'
  end
end

class TestProgramA < External::ExternalProgram
  def self.program_name
    './test_programs/versioning.rb'
  end
end

class TestExternalProgram < Test::Unit::TestCase

  def test_program_finding
    assert BashProgram.program_found?
    assert_equal false, BadProgram.program_found?

    assert TestProgramA.program_found?, 'Couldn\'t find test program "versioning.rb"'
  end

  def test_getting_program_version

    BashProgram.program_version
    TestProgramA.program_version

  end
  
end