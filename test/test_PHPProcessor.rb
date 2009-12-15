#
# File::       test_PHPProcessor.rb
# Author::     wkm
# Copyright::  2009
# License::    GPL
#
# Unit tests for the PHPProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/processors/PHPProcessor'

include SiteFuel::Processor

class TestPHPProcessor < Test::Unit::TestCase

  def test_file_extensions
    assert PHPProcessor.processes_file?('test.php')
    assert PHPProcessor.processes_file?('test.php5')
    assert PHPProcessor.processes_file?('test.phtml')
  end

  def test_name
    assert_equal 'PHP', PHPProcessor.processor_name
  end

  # test support for PHP documents
  def test_php
    assert_equal(
      "<html><head><title>PHP test</title></head><body><?php echo '<?>Hello World' ?> <p>Some filler text.</p> <? echo 'some more php! Weeee' ?> </body></html>",

      PHPProcessor.filter_string(:whitespace,
        %q{
          <html>
            <head>
              <title>PHP test</title>
            </head>
            <body>
              <?php echo '<p>Hello World</p>' ?>
              <p>Some filler text.</p>
              <? echo 'some more php! Weeee' ?>
            </body>
          </html>
        }
      )
    )
  end
  
end
