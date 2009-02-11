require File.dirname(__FILE__) + '/../../lib/johndown/tokenizer'
require 'test/unit'

class JohndownTest < Test::Unit::TestCase
  def setup
    @tokenizer = Tokenizer.new
  end

  #--------------------------------------------------------------------------
  # Tests for token matching
  #
  
  def test_string_and_newline
    string = "This is a string.\nWith a newline."
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "This is a string"],
                  Token::Type::PERIOD,
                  Token::Type::NEWLINE,
                  [Token::Type::STRING, "With a newline"],
                  Token::Type::PERIOD)
  end
  
  def test_carriage_returns
    string = "line one\r\nline two"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "line one"],
                  Token::Type::NEWLINE,
                  [Token::Type::STRING, "line two"])
  end

  def test_whitespace
    string = "   Whitespace only matches\n\n\tbetween  tokens"
    @tokenizer.scan(string)
    
    assert_tokens([Token::Type::WHITESPACE, "   "],
                  [Token::Type::STRING, "Whitespace only matches"],
                  Token::Type::NEWLINE,
                  Token::Type::NEWLINE,
                  [Token::Type::WHITESPACE, "\t"],
                  [Token::Type::STRING, "between  tokens"])
  end

  def test_tilde_and_asterisk
    string = "This has ~italics~ and *bold*"
    @tokenizer.scan(string)
    
    assert_tokens([Token::Type::STRING, "This has "],
                  Token::Type::TILDE,
                  [Token::Type::STRING, "italics"],
                  Token::Type::TILDE,
                  [Token::Type::WHITESPACE, ' '],
                  [Token::Type::STRING, "and "],
                  Token::Type::ASTERISK,
                  [Token::Type::STRING, "bold"],
                  Token::Type::ASTERISK)
  end

  def test_hash
    string = "Has # hash"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "Has "],
                  Token::Type::HASH,
                  [Token::Type::WHITESPACE, ' '],
                  [Token::Type::STRING, "hash"])
  end

  def test_url
    string = "A link: http://www.internet/"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "A link: "],
                  [Token::Type::URL, "http://www.internet/"])
  end

  def test_paren
    string = "This has (parentheses)"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "This has "],
                  Token::Type::LPAREN,
                  [Token::Type::STRING, "parentheses"],
                  Token::Type::RPAREN)
  end

  def test_backtick
    string = "This has `backticks`"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "This has "],
                  Token::Type::BACKTICK,
                  [Token::Type::STRING, "backticks"],
                  Token::Type::BACKTICK)
  end

  def test_less_than
    string = "Has < less than"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "Has "],
                  Token::Type::LESS_THAN,
                  [Token::Type::WHITESPACE, ' '],
                  [Token::Type::STRING, "less than"])
  end

  def test_greater_than
    string = "Has > greater than"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "Has "],
                  Token::Type::GREATER_THAN,
                  [Token::Type::WHITESPACE, ' '],
                  [Token::Type::STRING, "greater than"])
  end

  def test_ampersand
    string = "Has & ampersand"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "Has "],
                  Token::Type::AMPERSAND,
                  [Token::Type::WHITESPACE, " "],
                  [Token::Type::STRING, "ampersand"])
  end

  def test_code_block
    not_code = "Some text with :code: in it"
    @tokenizer.scan(not_code)
    assert_tokens([Token::Type::STRING, "Some text with "],
                  Token::Type::CODE_BLOCK,
                  [Token::Type::WHITESPACE, " "],
                  [Token::Type::STRING, "in it"])
    @tokenizer = Tokenizer.new
    
    string = ":code:\nSome code\n:code:"
    @tokenizer.scan(string)

    assert_tokens(Token::Type::CODE_BLOCK,
                  Token::Type::NEWLINE,
                  [Token::Type::STRING, "Some code"],
                  Token::Type::NEWLINE,
                  Token::Type::CODE_BLOCK)
  end

  def test_quote_block
    string = ":quote:\nA quotation\n:quote:"
    @tokenizer.scan(string)

    assert_tokens(Token::Type::QUOTE_BLOCK,
                  Token::Type::NEWLINE,
                  [Token::Type::STRING, "A quotation"],
                  Token::Type::NEWLINE,
                  Token::Type::QUOTE_BLOCK)
  end

  def test_dnf_block
    string = ":dnf:\nSome literal content\n:dnf:"
    @tokenizer.scan(string)

    assert_tokens(Token::Type::DNF_BLOCK,
                  Token::Type::NEWLINE,
                  [Token::Type::STRING, "Some literal content"],
                  Token::Type::NEWLINE,
                  Token::Type::DNF_BLOCK)
  end

  def test_digit_and_period
    string = "1. This has 2 digits and a period"
    @tokenizer.scan(string)
    
    assert_tokens([Token::Type::DIGIT, 1],
                  Token::Type::PERIOD,
                  [Token::Type::WHITESPACE, ' '],
                  [Token::Type::STRING, "This has "],
                  [Token::Type::DIGIT, 2],
                  [Token::Type::WHITESPACE, ' '],
                  [Token::Type::STRING, "digits and a period"])
  end

  def test_dash
    string = "This is a -"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "This is a "],
                  Token::Type::DASH)
  end

  def test_literal
    string = "A literal \\* character"
    @tokenizer.scan(string)

    assert_tokens([Token::Type::STRING, "A literal "],
                  [Token::Type::LITERAL, "*"],
                  [Token::Type::WHITESPACE, " "],
                  [Token::Type::STRING, "character"])
  end
  
  #--------------------------------------------------------------------------
  # Methods to access tokens
  #

  def test_tokens_block
    string = "This\nhas\ntokens"
    @tokenizer.scan(string)

    # Store a copy of the tokens to look for in the block
    tokens = @tokenizer.tokens.clone

    # Make sure the block is run
    block_run = false

    # Run the block
    @tokenizer.tokens do |t|
      block_run = true
      assert_equal t, tokens.shift
    end

    assert block_run
  end

  def test_peek
    string = "Two tokens\n"
    @tokenizer.scan(string)

    first_token = @tokenizer.peek
    assert_equal Token::Type::STRING, first_token.type
    assert_equal @tokenizer.tokens.first, first_token

    last_token = @tokenizer.peek(1)
    assert_equal Token::Type::NEWLINE, last_token.type
    assert_equal @tokenizer.tokens.last, last_token
  end

  def test_previous_token
    string = "This has\nmultiple tokens"
    @tokenizer.scan(string)

    prev = nil
    @tokenizer.tokens do |t|
      assert_equal prev, @tokenizer.previous_token
      prev = t
    end
  end

  private

  def assert_tokens (*tokens)
    assert_equal(tokens.length, @tokenizer.tokens.length,
                 @tokenizer.tokens.inspect)

    tokens.each do |next_token|
      t = @tokenizer.next_token
      assert_kind_of Token, t

      token = next_token
      content = nil
      
      if next_token.kind_of? Array
        (token, content) = next_token
      end

      assert_equal token, t.type
      assert_equal content, t.content
    end

    assert_nil @tokenizer.next_token
  end
end
