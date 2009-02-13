require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Tokenizer do
  before(:each) do
    @tokenizer = Tokenizer.new
  end

  describe "calling peek" do
    before(:each) do
      @tokenizer.scan("Two tokens\n")
    end

    describe "without an argument" do
      before(:each) do
        @token = @tokenizer.peek
      end

      it "should return the next token" do
        @token.should == @tokenizer.tokens.first
      end
      
      it "should not advance the position in the token stream" do
        @tokenizer.next_token.should == @token
      end
    end

    describe "with an argument" do
      before(:each) do
        @token = @tokenizer.peek(1)
      end

      it "should return the token at the position given" do
        @token.should == @tokenizer.tokens.last
      end
    end
  end
end