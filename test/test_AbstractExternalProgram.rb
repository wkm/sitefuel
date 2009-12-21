#
# File::      test_AbstractExternalProgram.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Unit tests for the AbstractExternalProgram wrapper.
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'

require 'sitefuel/external/AbstractExternalProgram'

include SiteFuel::External

# a wrapper around a generic program
class BashProgram < AbstractExternalProgram
  def self.program_name
    'bash'
  end
end

# a wrapper around a program which hopefully doesn't exist ;)
class BadProgram < AbstractExternalProgram
  def self.program_name
    'foo183127cowsaydog'
  end
end

class TestProgramA < AbstractExternalProgram
  def self.program_name
    './test/programs/versioning.rb'
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

  def test_version_less?

    # practical tests
    assert AbstractExternalProgram.version_older?('1.5', '1.5')

    assert AbstractExternalProgram.version_older?('1.5', '1.5.10')

    assert !AbstractExternalProgram.version_older?('1.5', '1.4')

    assert AbstractExternalProgram.version_older?('1.5', '1.5a')
    assert AbstractExternalProgram.version_older?('1.5', '1.5A')
    assert AbstractExternalProgram.version_older?('1.5', '1.5.a')
    assert AbstractExternalProgram.version_older?('1.5', '1.5.A')

    assert AbstractExternalProgram.version_older?('1.5', '1.51')
    assert AbstractExternalProgram.version_older?('1.5', '1.5.1')
    assert AbstractExternalProgram.version_older?('1.5', '1.5.0')

    assert AbstractExternalProgram.version_older?('1.5', '2')
    assert AbstractExternalProgram.version_older?('1.5', '2.0')
    assert AbstractExternalProgram.version_older?('1.5', '2.1')
    assert AbstractExternalProgram.version_older?('1.5', '5.1.5')

    assert AbstractExternalProgram.version_older?('1.5.2', '1.5.2')
    assert AbstractExternalProgram.version_older?('1.5.2', '1.5.3')
    assert AbstractExternalProgram.version_older?('1.5.2', '1.5.2')
    assert AbstractExternalProgram.version_older?('1.5.2', '1.6')
    assert AbstractExternalProgram.version_older?('1.5.2', '2')

    assert !AbstractExternalProgram.version_older?('1.5.2', '1.5')
    
    assert !AbstractExternalProgram.version_older?('1a', '1')
  end

  def test_test_version_number
    assert AbstractExternalProgram.test_version_number('> 1.5', '1.5')
    assert AbstractExternalProgram.test_version_number('> 1.5', '1.5.10')
    
    assert AbstractExternalProgram.test_version_number(['> 1.5'], '1.5.10')
  end

  def test_option_organizing
    assert_equal [], AbstractExternalProgram.organize_options()
    assert_equal [[:a],[:b],[:c]], AbstractExternalProgram.organize_options(:a, :b, :c)
    assert_equal(
            [[:a], [:b, 'val'], [:c]],
            AbstractExternalProgram.organize_options(:a,
                                                     :b, 'val',
                                                     :c)
    )

    assert_equal(
            [[:a, 'val1'], [:b, 'val2'], [:c, 'val3']],
            AbstractExternalProgram.organize_options(:a, 'val1',
                                                     :b, 'val2',
                                                     :c, 'val3')
    )

    assert_equal(
            [[:a, 'val1', 'val2']],
            AbstractExternalProgram.organize_options(:a, 'val1', 'val2')
    )
  end


  def test_option_creation
    # here we want to test the sanity checks that are preformed when an option
    # is created

    # if there is a default there must be ${value} slot
    assert_raises NoOptionValueSlot do
      TestProgramA.option(:option1, '--someflag', 'defaultvalue')
    end

    # make sure the option wasn't added
    assert !TestProgramA.options.include?(:option1)

    # if there is a ${value} slot and no default, the option must
    # have a value when it's being set
    assert_nothing_raised { TestProgramA.option(:optionNoDef, '--someopt ${value}') }
    assert_raises NoValueForOption do
      TestProgramA.execute(:optionNoDef)
    end
  end
  
end
