require File.join(File.dirname(__FILE__), 'block')
require File.join(File.dirname(__FILE__), 'content')

$debug = false

class Parser
  def initialize(string)
    @tokenizer = Tokenizer.new
    @tokenizer.scan(string)
  end

  def blocks
    @blocks ||= parse_top_level_blocks
  end

  def parse_top_level_blocks
    blocks = []
    loop_count = 0
    limit = @tokenizer.tokens.size
    until @tokenizer.peek == nil
      block = nil

      if match_tokens(Token::Type::NEWLINE)
        eat
      elsif match_line(Token::Type::QUOTE_BLOCK)
        block = parse_quotation

      else
        block = parse_paragraph
      end
      
      blocks << block if block
      
      loop_count += 1
      raise "Infinite parsing loop. Parser is broken" if loop_count > limit
    end

    blocks
  end

  def parse_paragraph
    parse_block(
      Block::Type::PARAGRAPH,
      Token::Type::NEWLINE, Token::Type::NEWLINE
    )
  end

  def parse_quotation
    eat(2) # The quote token and newline

    parse_block(Block::Type::BLOCKQUOTE, Token::Type::QUOTE_BLOCK) do
      content = nil

      if match_tokens(Token::Type::DASH, Token::Type::DASH)
        eat(2)
        eat_while(Token::Type::WHITESPACE)
        content = parse_block(Block::Type::CITATION, Token::Type::NEWLINE)
      end

      content
    end
  end

  def parse_block (type, *closing, &block)
    content = Content.new
    finished = false

    puts "Parsing #{type} #{@tokenizer.tokens.inspect}" if $debug

    until finished
      block_content = nil
      if block_given?
        block_content = yield
      end

      if ! block_content.nil?
        content << block_content
      elsif match_tokens(nil)
        puts "Finished tokenizing due to EOF" if $debug
        finished = true

      elsif match_tokens(*closing)
        puts "Finished tokenizing due to double newline" if $debug
        eat(2)
        finished = true

      else
        content << default_parsing
      end
    end

    if content.last == "\n"
      content.pop
    end

    puts "Adding #{type} block #{content.inspect}" if $debug
    Block.new(type, content)
  end


  def parse_inline(type, closing)
    content = Content.new
    finished = false

    puts "\tParsing #{type} #{@tokenizer.peek.inspect}" if $debug

    until finished
      if match_tokens(nil)
        finished = true

      elsif match_tokens(closing)
        eat
        finished = true

      elsif match_tokens(Token::Type::NEWLINE, Token::Type::NEWLINE)
        finished = true

      else
        content << default_parsing
      end
    end

    puts "\tAdding #{type} block #{content}" if $debug
    Block.new(type, content)
  end


  def default_parsing
    content = nil

    puts "Parsing inline #{@tokenizer.peek.inspect}" if $debug

    if match_tokens(nil)
      # Finish the inline parsing.

    elsif match_tokens(Token::Type::TILDE)
      eat
      content = parse_inline(Block::Type::EM, Token::Type::TILDE)

    elsif match_tokens(Token::Type::ASTERISK)
      eat
      content = parse_inline(Block::Type::STRONG, Token::Type::ASTERISK)

    elsif match_tokens(Token::Type::DASH, Token::Type::DASH)
      eat
      eat
      content = Block.new(Block::Type::MDASH)

    else
      content = eat.literal
    end

    content
  end

  protected

  def match_tokens (*expected_tokens)
    offset = 0
    match = false
    puts "\t* Lookahead called for #{expected_tokens.inspect}" if $debug

    expected_tokens.each do |expected_token_set|
      match = false
      token = @tokenizer.peek(offset)
      puts "\t* Checking #{token.inspect} against #{expected_token_set.inspect}" if $debug

      if token && expected_token_set.kind_of?(Array)
        match = expected_token_set.include?(token.type)

      elsif expected_token_set.kind_of?(Array)
        # Token is nil if we get here
        match = expected_token_set.include?(nil)

      elsif (token && token.type == expected_token_set) or
          (token.nil? && expected_token_set.nil?)
        match = true
      end

      return false if match == false
      offset += 1
    end

    match
  end

  def match_line (*expected_tokens)
    match_tokens(expected_tokens) &&
      starts_line &&
      ends_line(expected_tokens.to_a.size)
  end

  def starts_line
    @tokenizer.previous_token.nil? ||
      @tokenizer.previous_token.type == Token::Type::NEWLINE
  end

  def ends_line (line_length)
    @tokenizer.peek(line_length).nil? ||
      @tokenizer.peek(line_length).type == Token::Type::NEWLINE
  end
    

  def eat_while (token_type)
    next_token = @tokenizer.peek
    while (next_token && next_token.type == token_type)
      eat
      next_token = @tokenizer.peek
    end
  end

  def eat (token_count = 1)
    token = nil
    token_count.times do
      token = @tokenizer.next_token
    end
    token
  end
end
