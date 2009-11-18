#
# File::      StringFormatting.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

class String

  # gives an abbreviated form of a string
  def abbrev(len)
    if length <= len
      self
    else
      self[0..(len/2-2).floor] + "..." + self[(length - len/2+2) .. (length)]
    end
  end
end
