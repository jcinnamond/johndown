require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Token do
  it "should return the token type" do
    t = Token.new(Token::Type::STRING)
    t.type.should == Token::Type::STRING
  end

  it "should return the token content" do
    content = "This is some content"
    t = Token.new(Token::Type::STRING, content)
    t.content.should == content
  end

  describe "literal" do
    it "should return ( for LPAREN token" do
      t = Token.new(Token::Type::LPAREN)
      t.literal.should == '('
    end

    it "should return ) for RPAREN token" do
      t = Token.new(Token::Type::RPAREN)
      t.literal.should == ')'
    end

    it "should return ~ for TILDE token" do
      t = Token.new(Token::Type::TILDE)
      t.literal.should == '~'
    end

    it "should return the string for a STRING token" do
      string = "some literal string"
      t = Token.new(Token::Type::STRING, string)
      t.literal.should == string
    end

    it "should return an empty STRING token" do
      t = Token.new(Token::Type::STRING)
      t.literal.should == ""
    end

    it "should return nil for an empty URL token" do
      t = Token.new(Token::Type::URL)
      t.literal.should be_nil
    end
  end

  describe "escaped literal" do
    it "should return &amp; for &" do
      t = Token.new(Token::Type::AMPERSAND)
      t.escaped_literal.should == '&amp;'
    end

    it "should return &lt; for <" do
      t = Token.new(Token::Type::LESS_THAN)
      t.escaped_literal.should == '&lt;'
    end

    it "should return &gt; for >" do
      t = Token.new(Token::Type::GREATER_THAN)
      t.escaped_literal.should == '&gt;'
    end

    it "should return the literal if no escaped literal exists" do
      string = "some literal string"
      t = Token.new(Token::Type::STRING, string)
      t.escaped_literal.should == string
    end
  end
end