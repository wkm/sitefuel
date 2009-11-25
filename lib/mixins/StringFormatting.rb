#
# File::      StringFormatting.rb
# Author::    wkm
# Copyright:: 2009
# License::   GPL
#
# Adds String#cabbrev for abbreviating strings
#

class String

  # gives an abbreviated form of a string, showing some of the beginning
  # and some of the end.
  # 
  #  "the quick brown dog".cabbrev 12  # => "the q... dog"
  def cabbrev(len)
    if length <= len
      self
    else
      self[0..(len/2-2).floor] + "..." + self[(length - len/2+2) .. (length)]
    end
  end

  # gives an abbreviated form of the string, showing as much of the beginning
  # as possible
  #
  #  "the quick brown dog".labbrev 12  # => "the quick ..."
  def labbrev(len)
    if length <= len
      self
    else
      self[0..(len-4)] + '...'
    end
  end

  # gives an abbreviated form of the string, showing as much of the end as
  # possible
  #
  #  "the quick brown dog".rabbrev 12  # => "...brown dog"
  def rabbrev(len)
    if length <= len
      self
    else
      '...' + self[(length - (len-3)) .. length]
    end
  end
end
