#
# File::      StringFormatting.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Adds String#cabbrev for abbreviating strings. Note that this function
# correctly supports ANSI sequences in strings (ie. it ignores them when
# computing sizes)
#
# Adds String#align for stripping leading whitespace from multiple lines in
# a string.
#

require 'term/ansicolor'

include Term::ANSIColor

class String

  # gives the apparent length of the string (ignoring ASCII sequences)
  def visual_length
    uncolored.length
  end


  # gives the difference between the actual and apparent length of the string
  def visual_length_delta
    length - visual_length
  end


  # like #ljust but uses the apparent length
  def visual_ljust(width, padding = " ")
    ljust(width + visual_length_delta, padding)
  end


  # gives an abbreviated form of a string, showing some of the beginning
  # and some of the end.
  # 
  #  "the quick brown dog".cabbrev 12  # => "the q... dog"
  def cabbrev(len)
    real_length = uncolored.length
    if real_length <= len
      self
    else
      self[0..(len/2-2).floor] + "..." + self[(real_length - len/2+2) .. (real_length)]
    end
  end


  # gives an abbreviated form of the string, showing as much of the beginning
  # as possible
  #
  #  "the quick brown dog".labbrev 12  # => "the quick ..."
  def labbrev(len)
    if uncolored.length <= len
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
    real_length = uncolored.length
    if real_length <= len
      self
    else
      '...' + self[(real_length - (len-3)) .. real_length]
    end
  end
  

  # removes leading whitespace from a set of lines, preserving indentation
  # relative to the first non-empty line
  def align
    return self if empty?

    # split by lines
    lines = split("\n")

    # get rid of the first line if it is null
    if lines.first == ''
      lines = lines[1..-1]
    end

    # take the first line and extract the leading whitespace
    leading = lines.first[/^[ \t]*/]

    # iterate over each line dumping the leading whitespace
    lines = lines.map do |l|
      l.gsub!(Regexp.new('^'+leading), '')
    end

    lines.join("\n")
  end


  alias :format :%

end
