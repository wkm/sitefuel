#
# File::      FileComparison.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Adds File.equivalent? that tries to guess whether two files are equivalent
#

require 'extensions/ArrayComparisons'

class File
  # gives true if one of the paths is the ending of another path
  #
  #  File.equivalent?('b/a.rb', 'a.rb')  # ==> true
  #  File.equivalent?('c/b/a.rb', 'c/a.rb')  # ==> false
  def self.equivalent?(a, b)
    list = [
      File.expand_path(a, '/').split(File::SEPARATOR)[1 .. -1],
      File.expand_path(b, '/').split(File::SEPARATOR)[1 .. -1]
    ].sort {|l,r| l.length <=> r.length }.reverse
    list.first.ends_with? list.last
  end
end
