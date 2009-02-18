require File.join(File.dirname(__FILE__), 'block')

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

      if match_tokens(Token::Type::NEWLINE)
        eat
      else
        block = parse_paragraph
        puts "\n\nAdding block #{block.inspect}" if $debug
        blocks << block if block
      end
      
      loop_count += 1
      raise "Infinite parsing loop. Parser is broken" if loop_count > limit
    end

    puts "Returning #{blocks.inspect}" if $debug
    blocks
  end

  def parse_paragraph
    content = []
    finished = false

    puts "Parsing paragraph #{@tokenizer.tokens.inspect}" if $debug

    until finished
      if match_tokens(nil)
        puts "Finished tokenizing due to EOF" if $debug
        finished = true

      elsif match_tokens(Token::Type::NEWLINE, Token::Type::NEWLINE)
        puts "Finished tokenizing due to double newline" if $debug
        eat(2)
        finished = true

      else
        content << default_parsing
      end
    end

    puts "Adding paragraph block #{content.inspect}" if $debug
    Block.new(Block::Type::PARAGRAPH, content)
  end


  def parse_inline(type, closing)
    content = []
    finished = false

    puts "\tParsing #{type} #{@tokenizer.peek.inspect}" if $debug

    until finished
      if match_tokens(nil)
        finished = true

      elsif match_tokens(closing)
        eat
        finished = true

      elsif match_tokens(Token::Type::NEWLINE, Token::Type::NEWLINE)
        # Auto close ~ at the end of the block
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

    elsif match_tokens([
          Token::Type::STRING,
          Token::Type::WHITESPACE,
          Token::Type::NEWLINE,
          Token::Type::DASH
        ])
      content = eat.literal

    else
      raise "Unexpected token: #{@tokenizer.peek.inspect}"
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
    

  def eat (token_count = 1)
    token = nil
    token_count.times do
      token = @tokenizer.next_token
    end
    token
  end
end
