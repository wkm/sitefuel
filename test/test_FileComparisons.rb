$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'mixins/FileComparison'

class TestFileComparion < Test::Unit::TestCase
  def test_equivalent

    # files which are clearly not equivalent
    assert !File.equivalent?('a.rb', 'b.rb')
    assert !File.equivalent?('f/a.rb', 'f/b.rb')
    assert !File.equivalent?('b/a.rb', 'c/a.rb')
    assert !File.equivalent?('c/b/a.rb', 'c/a.rb')

    # files which are potentially equivalent
    assert File.equivalent?('b/a.rb', 'a.rb')
    assert File.equivalent?('./a.rb', 'b/a.rb')
    assert File.equivalent?('b/a.rb', 'b/a.rb')
    assert File.equivalent?('../a.rb', './a.rb')
    assert File.equivalent?('../../../.././../a.rb', 'a.rb')

    # trivial, but incorrect, variations on the potentially
    # equivalent files above
    assert !File.equivalent?('./a.rb', 'b/c.rb')
    assert !File.equivalent?('b/a.rb', 'c/a.rb')
    assert !File.equivalent?('b/a.rb', 'b/c.rb')
    assert !File.equivalent?('../a.rb', './b.rb')
    assert !File.equivalent?('../../../.././../a.rb', 'b.rb')

  end
end