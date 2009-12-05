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

  def self.compatible_versions
    '> 0.1'
  end
end

class TestProgramB < TestProgramA
  def self.option_version
    '--version-2'
  end

  def self.compatible_versions
    '> 0.1.2'
  end
end

class TestProgramC < TestProgramA
  def self.option_version
    '--version-3'
  end

  def self.compatible_versions
    '> 0.1.5'
  end
end

class TestProgramD < TestProgramA
  def self.option_version
    '--version-4'
  end

  def self.compatible_versions
    '> 0.5.2'
  end
end

class TestExternalProgram < Test::Unit::TestCase

  def test_program_finding
    assert BashProgram.program_found?
    assert_equal false, BadProgram.program_found?

    assert TestProgramA.program_found?, 'Couldn\'t find test program "versioning.rb"'
  end

  def test_getting_program_version

    # no real point testing against the bash version, who knows
    # what they're running; just make sure we can get a version
    assert_not_nil BashProgram.program_version

    assert_equal '0.1.2', TestProgramA.program_version
    assert_equal '0.1.2asdad', TestProgramB.program_version
    assert_equal '0.2', TestProgramC.program_version
    assert_equal '0.1.2', TestProgramD.program_version

  end

  def test_compatible_version
    assert TestProgramA.compatible_version?
    assert TestProgramB.compatible_version?
    assert TestProgramC.compatible_version?
    assert_equal false, TestProgramD.compatible_version?
  end

  def test_compatible_version_number?
    
  end
  
end