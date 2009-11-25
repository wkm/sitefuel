#
# File::      ArrayComparisons.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Adds methods to Array for comparing with other arrays
#

class Array

  # gives true if self ends with the given array
  #
  #  [1, 2, 3].ends_with? [2, 3]  # ==> true
  #  [1, 2, 3].ends_with? []  # ==> true
  #  [1, 2, 3].ends_with? [1, 2, 3]  # ==> true
  #  [1, 2, 3].ends_with? [1, 2]  # ==> false
  def ends_with?(other)
    index = -1
    while -index <= other.length and -index <= length
      if other[index] != self[index]
        return false
      end
      index -= 1
    end
    
    return true
  end
end