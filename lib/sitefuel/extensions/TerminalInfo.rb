#
# File::      TerminalInfo.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Little Ruby library for querying for various properties of
# a terminal window.
#

module TerminalInfo

  # gives an array containing the current dimensions of the terminal
  # window
  #
  # Note that unlike =stty= (and #size) the first parameter is the width of
  # the window (x) and the second parameter is the height of the window (y)
  #
  #  TerminalInfo.dimensions # => [105, 34]
  def self.dimensions
    grab_output('stty size').split(' ').reverse.map do |val|
      val.to_i
    end
  end

  # gives an array with the current size of the terminal window
  #
  # Note that the first parameter is the height of the window, just like with
  # =stty=
  #
  #  TerminalInfo.size # => [34, 105]
  def self.size
    dimensions.reverse
  end

  # gives the current width of the terminal window
  def self.width
    dimensions.first
  end

  # gives the current height of the terminal window
  def self.height
    dimensions.last
  end

private

  # the back tick notation is annoying to read... 
  def self.grab_output(command)
    `#{command}`
  end

end