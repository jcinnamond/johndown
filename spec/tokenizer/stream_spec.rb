require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Tokenizer do
  before(:each) do
    @tokenizer = Tokenizer.new
    @tokenizer.scan("This has three tokens\nincluding a newline")
  end

  describe "next token" do
    it "should initially return the first token" do
      @tokenizer.next_token.should match_token(
        [Token::Type::STRING, "This has three tokens"]
      )
    end

    it "should subsequently return the second token" do
      @tokenizer.next_token
      @tokenizer.next_token.should match_token(Token::Type::NEWLINE)
    end

    it "should return nill when there are no more tokens" do
      @tokenizer.next_token
      @tokenizer.next_token
      @tokenizer.next_token
      @tokenizer.next_token.should be_nil
    end
  end

  describe "previous token" do
    it "should initially return nil" do
      @tokenizer.previous_token.should be_nil
    end

    it "should return the previous token" do
      @tokenizer.next_token # This is really the first token
      @tokenizer.next_token
      @tokenizer.previous_token.should match_token(
        [Token::Type::STRING, "This has three tokens"]
      )
    end

    it "should mirror next_token" do
      token = @tokenizer.next_token  # This is really the first token
      @tokenizer.next_token
      @tokenizer.previous_token.should == token
    end
  end
end