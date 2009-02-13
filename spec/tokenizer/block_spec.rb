require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Tokenizer do
  describe "called tokens as a block" do
    before(:each) do
      @tokenizer = Tokenizer.new
      @tokenizer.scan("This has three tokens\nincluding a newline")
    end

    it "should call the block" do
      block_run = false
      @tokenizer.tokens do
        block_run = true
      end
      block_run.should be_true
    end

    it "should pass in three tokens" do
      expected_tokens = [
        [Token::Type::STRING, "This has three tokens"],
        Token::Type::NEWLINE,
        [Token::Type::STRING, "including a newline"]
      ]

      @tokenizer.tokens do |token|
        token.should match_token(expected_tokens.shift)
      end
    end
  end
end