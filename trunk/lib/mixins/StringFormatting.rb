#
# File::      StringFormatting.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#

class String

  # gives an abbreviated form of a string, showing some of the beginning
  # and some of the end.
  # 
  #  "the quick brown dog".abbrev 12  # => "the q... dog"
  def abbrev(len)
    if length <= len
      self
    else
      self[0..(len/2-2).floor] + "..." + self[(length - len/2+2) .. (length)]
    end
  end

  p "the quick brown dog".abbrev 12
end
