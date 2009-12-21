#
# File::      test_RHTMLProcessor.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Unit tests for the RHTMLProcessor
#

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'sitefuel/processors/RHTMLProcessor'

include SiteFuel::Processor

class TestRHTMLProcessor < Test::Unit::TestCase

  def test_file_extensions
    assert RHTMLProcessor.processes_file?('test.rhtml')
    assert RHTMLProcessor.processes_file?('test.erb')
  end

  def test_name
    assert_equal 'RHTML', RHTMLProcessor.processor_name
  end

  # test support for RHTML documents (really testing hpricot here)
  def test_rhtml
    assert_equal(
      "<html><head><title>Goodbye, World.</title></head><body><h1>Goodbye!</h1> <% 5.times do || %> <p>and again...</p> <% end %> </body></html>",
      RHTMLProcessor.filter_string(:whitespace,
        %q{
          <html>
            <head>
              <title>Goodbye, World.</title>
            </head>
            <body>
              <h1>Goodbye!</h1>
              <% 5.times do || %>
                <p>and again...</p>
              <% end %>
            </body>
          </html>
        }
      )
    )

    assert_equal(
      "<html> <%= page.title %> </html>",

      RHTMLProcessor.filter_string(:whitespace,
        %q{
          <html>
            <%= page.title %>
          </html>
        }
      )
    )
  end

end