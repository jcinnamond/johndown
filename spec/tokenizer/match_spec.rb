require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Tokenizer do
  describe "whole_line_match" do
    before(:each) do
      @tokenizer = Tokenizer.new
      @tokenizer.scan(':code:\nsome code\n:code:')
    end

    it "should return true if the next line matches the given token" do
      @tokenizer.whole_line_match(Token::Type::CODE_BLOCK).should be_true
    end
  end
end