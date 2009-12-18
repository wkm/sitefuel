#
# File::      SymbolComparison.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
#
# Defines a spaceship for symbols based off of to_s
#

class Symbol
  def <=>(other)
    self.to_s <=> other.to_s
  end
end