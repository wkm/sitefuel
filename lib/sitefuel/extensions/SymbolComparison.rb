#
# File::      SymbolComparison.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0
#
# Defines a spaceship for symbols based off of to_s
#

class Symbol
  def <=>(other)
    self.to_s <=> other.to_s
  end
end