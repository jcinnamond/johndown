require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Tokenizer do
  before(:each) do
    @tokenizer = Tokenizer.new
  end

  it "should tokenize strings and newlines" do
    string = "This is a string.\nWith a newline."
    @tokenizer.scan(string)
    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "This is a string"],
      Token::Type::PERIOD,
      Token::Type::NEWLINE,
      [Token::Type::STRING, "With a newline"],
      Token::Type::PERIOD
    )
  end

  it "should tokenize carriage returns" do
    string = "line one\r\nline two"
    @tokenizer.scan(string)
    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "line one"],
      Token::Type::NEWLINE,
      [Token::Type::STRING, "line two"]
    )
  end

  it "should tokenize whitespace between tokens" do
    string = "   Whitespace only matches\n\n\tbetween  tokens"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::WHITESPACE, "   "],
      [Token::Type::STRING, "Whitespace only matches"],
      Token::Type::NEWLINE,
      Token::Type::NEWLINE,
      [Token::Type::WHITESPACE, "\t"],
      [Token::Type::STRING, "between  tokens"]
    )
  end

  it "should tokenize ~ and *" do
    string = "This has ~italics~ and *bold*"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "This has "],
      Token::Type::TILDE,
      [Token::Type::STRING, "italics"],
      Token::Type::TILDE,
      [Token::Type::WHITESPACE, ' '],
      [Token::Type::STRING, "and "],
      Token::Type::ASTERISK,
      [Token::Type::STRING, "bold"],
      Token::Type::ASTERISK
    )
  end

  it "should tokenize #" do
    string = "Has # hash"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "Has "],
      Token::Type::HASH,
      [Token::Type::WHITESPACE, ' '],
      [Token::Type::STRING, "hash"]
    )
  end

  it "should tokenize URLs" do
    string = "A link: http://www.internet/"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "A link: "],
      [Token::Type::URL, "http://www.internet/"]
    )
  end

  it "should tokenizer URLs surrounded by parentheses" do
    string = "A link: (http://www.internet/)."
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "A link: "],
      [Token::Type::URL, "http://www.internet/"],
      [Token::Type::PERIOD]
    )
  end

  it "should tokenize parentheses" do
    string = "This has (parentheses)"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "This has "],
      Token::Type::LPAREN,
      [Token::Type::STRING, "parentheses"],
      Token::Type::RPAREN
    )
  end

  it "should tokenize backticks" do
    string = "This has `backticks`"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "This has "],
      Token::Type::BACKTICK,
      [Token::Type::STRING, "backticks"],
      Token::Type::BACKTICK
    )
  end

  it "should tokenize <" do
    string = "Has < less than"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "Has "],
      Token::Type::LESS_THAN,
      [Token::Type::WHITESPACE, ' '],
      [Token::Type::STRING, "less than"]
    )
  end

  it "should tokenize >" do
    string = "Has > greater than"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "Has "],
      Token::Type::GREATER_THAN,
      [Token::Type::WHITESPACE, ' '],
      [Token::Type::STRING, "greater than"]
    )
  end

  it "should tokenize &" do
    string = "Has & ampersand"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "Has "],
      Token::Type::AMPERSAND,
      [Token::Type::WHITESPACE, " "],
      [Token::Type::STRING, "ampersand"]
    )
  end

  it "should tokenize code blocks" do
    string = ":code:\nSome code\n:code:"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      Token::Type::CODE_BLOCK,
      Token::Type::NEWLINE,
      [Token::Type::STRING, "Some code"],
      Token::Type::NEWLINE,
      Token::Type::CODE_BLOCK
    )
  end

  it "should tokenize quote blocks" do
    string = ":quote:\nA quotation\n:quote:"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      Token::Type::QUOTE_BLOCK,
      Token::Type::NEWLINE,
      [Token::Type::STRING, "A quotation"],
      Token::Type::NEWLINE,
      Token::Type::QUOTE_BLOCK
    )
  end

  it "should tokenize dnf blocks" do
    string = ":dnf:\nSome literal content\n:dnf:"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      Token::Type::DNF_BLOCK,
      Token::Type::NEWLINE,
      [Token::Type::STRING, "Some literal content"],
      Token::Type::NEWLINE,
      Token::Type::DNF_BLOCK
    )
  end

  it "should tokenize digits and periods" do
    string = "1. This has 2 digits and a period"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::DIGIT, 1],
      Token::Type::PERIOD,
      [Token::Type::WHITESPACE, ' '],
      [Token::Type::STRING, "This has "],
      [Token::Type::DIGIT, 2],
      [Token::Type::WHITESPACE, ' '],
      [Token::Type::STRING, "digits and a period"]
    )
  end

  it "should tokenize dashes" do
    string = "This is a -"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "This is a "],
      Token::Type::DASH
    )
  end

  it "should tokenize literal characters" do
    string = "A literal \\* character"
    @tokenizer.scan(string)

    @tokenizer.should have_token_stream(
      [Token::Type::STRING, "A literal "],
      [Token::Type::LITERAL, "*"],
      [Token::Type::WHITESPACE, " "],
      [Token::Type::STRING, "character"]
    )
  end
end