require "rubygems"
require "test/unit"
require "mocha"
require File.dirname(__FILE__) + "/../lib/mos_eisley"

# siehe http://blog.jayfields.com/2007/11/ruby-testing-private-methods.html
class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public( *saved_private_instance_methods) }
    yield
    self.class_eval { private( *saved_private_instance_methods) }
  end
end