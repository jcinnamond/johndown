require File.dirname(__FILE__) + '/../../lib/johndown/token'
require 'test/unit'

class TokenTest < Test::Unit::TestCase
  def test_type
    t = Token.new(Token::Type::STRING)
    assert_kind_of Token, t
    assert_equal Token::Type::STRING, t.type
  end

  def test_content
    content = "This is some content"
    t = Token.new(Token::Type::STRING, content)
    assert_kind_of Token, t
    assert_equal content, t.content

    addition = "More content"
    content += addition
    t.content << addition
    assert_equal(content, t.content)
  end

  def test_literal
    t = Token.new(Token::Type::LPAREN)
    assert_equal '(', t.literal

    t2 = Token.new(Token::Type::TILDE)
    assert_equal '~', t2.literal

    t3 = Token.new(Token::Type::URL)
    assert_nil t3.literal

    string = "wooyeah"
    t4 = Token.new(Token::Type::STRING, string)
    assert_equal string, t4.literal
  end

  def test_escaped_literal
    t = Token.new(Token::Type::LESS_THAN)
    assert_equal '<', t.literal
    assert_equal '&lt;', t.escaped_literal

    t2 = Token.new(Token::Type::TILDE)
    assert_equal '~', t2.literal
    assert_equal '~', t2.escaped_literal

    string = "wooyeah"
    t3 = Token.new(Token::Type::STRING, string)
    assert_equal string, t3.literal
    assert_equal string, t3.escaped_literal
  end
end
