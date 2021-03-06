#
# File::      SymbolComparison.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Defines a spaceship for symbols based off of to_s, this let's us sort lists
# of symbols.
#

class Symbol
  def <=>(other)
    self.to_s <=> other.to_s
  end
end