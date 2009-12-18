#
# File::      test_ColumnPrinter.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Unit tests for the ColumnPrinter
#

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'sitefuel/extensions/ColumnPrinter'

class TestColumnPrinter < Test::Unit::TestCase

  def test_basic
    p = ColumnPrinter.new([5, 10, 5], 30)
    assert_equal(
      " 1     2          3     ",
      p.format_row(1, 2, 3)
    )
    assert_equal(
      " 1...  48182      1...  ",
      p.format_row(123131, 48182, 123131)
    )
  end

  def test_spanning
    p = ColumnPrinter.new([10, :span, 20], 50)
    assert_equal(
      " PNG        some text here   value                ",
      p.format_row('PNG', 'some text here', 'value')
    )
    
    # the important thing is that it actually fits, however
    assert p.format_row('PNG', 'some text here', 'value').length <= 50
  end

end