require File.join(File.dirname(__FILE__), '..', 'spec_helper')

def johndown (str)
  Johndown.new(str).to_s
end
