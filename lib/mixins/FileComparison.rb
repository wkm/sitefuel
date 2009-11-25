#
# File::      FileComparison.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Adds File.equivalent? that tries to guess whether two files are equivalent
#

class File
  def self.equivalent?(a, b)
    fa = File.expand_path(a)
    fb = File.expand_path(b)
    p fa, fb
  end
end
