#
# File::      DynamicClassMethods.rb
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Adds a #meta_def function to Object so we can programmatically define class
# methods.
#

class Object

  # defines a class method
  # based on: http://blog.jayfields.com/2007/10/ruby-defining-class-methods.html
  # and: http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  def define_class_method name, &blk
    (class << self; self; end).instance_eval { define_method name, &blk}
  end
end