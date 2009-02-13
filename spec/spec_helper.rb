$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'spec'

require File.join(File.dirname(__FILE__), 'matchers', 'custom_token_matchers')

Spec::Runner.configure do |config|
  config.include(CustomTokenMatchers)
end

require 'johndown'