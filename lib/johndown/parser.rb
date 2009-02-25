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

      elsif match_line(
          Token::Type::DASH, Token::Type::DASH, Token::Type::DASH,
          [Token::Type::DASH, nil], [Token::Type::DASH, nil]
        )
        block = parse_hr

      elsif match_line(Token::Type::CODE_BLOCK)
        block = parse_code(eat.type)

      elsif match_line(Token::Type::BACKTICK)
        block = parse_code(eat.type)

      elsif match_line(Token::Type::DNF_BLOCK)
        block = parse_dnf

      elsif match_tokens(Token::Type::HASH) && starts_line
        block = parse_heading

      elsif match_tokens(Token::Type::DASH) && starts_line
        block = parse_ul

      elsif match_tokens(
          Token::Type::DIGIT, Token::Type::PERIOD, Token::Type::WHITESPACE
        ) && starts_line
        block = parse_ol

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

  def parse_code (closing_type)
    eat # The newline
    parse_block(Block::Type::CODE_BLOCK, closing_type) do
      content = nil

      if match_tokens(Token::Type::BACKTICK)
        if closing_type != Token::Type::BACKTICK ||
            ! match_line(Token::Type::BACKTICK)
          content = eat.literal
        end
      end

      content
    end
  end

  def parse_dnf
    eat(2) # The :dnf: and the newline
    content = Content.new
    finished = false

    until finished
      if match_tokens(nil)
        finished  = true

      elsif match_line(Token::Type::DNF_BLOCK)
        eat
        finished = true

      else
        content << eat.literal
      end
    end

    content.trim
    Block.new(Block::Type::DNF, content)
  end

  def parse_hr
    eat_while(Token::Type::DASH) # Dashes
    eat                          # and newline
    Block.new(Block::Type::HR, [])
  end

  def parse_heading
    level = eat_while(Token::Type::HASH).size
    eat_while(Token::Type::WHITESPACE)
    content = default_parsing
    Block.new(Block::Type::HEADING, [level, content])
  end

  def parse_ol
    parse_list(Block::Type::OL, Token::Type::DIGIT, Token::Type::PERIOD)
  end

  def parse_ul
    parse_list(Block::Type::UL, Token::Type::DASH)
  end

  def parse_list(type, *next_element)
    eat(next_element.size)
    eat_while(Token::Type::WHITESPACE)

    list_content = Content.new
    li_content = Content.new
    
    finished = false

    until finished
      if match_tokens(nil)
        unless li_content.empty?
          li_content.trim
          list_content << Block.new(Block::Type::LI, li_content)
        end
        finished = true

      elsif match_tokens(*next_element) && starts_line
        eat(next_element.size)
        eat_while(Token::Type::WHITESPACE)
        li_content.trim
        list_content << Block.new(Block::Type::LI, li_content)
        li_content = Content.new

      elsif match_tokens(Token::Type::WHITESPACE)
        eat

      elsif match_tokens(Token::Type::NEWLINE, Token::Type::NEWLINE)
        eat(2)

      elsif starts_line
        unless li_content.empty?
          li_content.trim
          list_content << Block.new(Block::Type::LI, li_content)
        end
        finished = true

      else
        li_content << default_parsing
      end
    end

    Block.new(type, list_content)
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
        eat(closing.size)
        finished = true

      else
        content << default_parsing
      end
    end

    content.trim

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

    elsif match_tokens(Token::Type::BACKTICK)
      eat
      content = parse_inline(Block::Type::INLINE_CODE, Token::Type::BACKTICK)

    elsif match_tokens(Token::Type::DASH, Token::Type::DASH)
      eat(2)
      if match_tokens(Token::Type::WHITESPACE)
        content = Block.new(Block::Type::MDASH)
      else
        content = "--"
        content += eat_while(Token::Type::DASH).map { |t| t.literal }.join()
      end

    elsif match_tokens(
        Token::Type::LPAREN,
        Token::Type::STRING,
        Token::Type::RPAREN,
        Token::Type::URL,
        :skip_whitespace => true
      )
      eat
      eat_while(Token::Type::WHITESPACE)
      name = eat
      eat_while(Token::Type::WHITESPACE)
      eat
      eat_while(Token::Type::WHITESPACE)
      url = eat
      content = Block.new(Block::Type::LINK, [name.literal, url.literal])

    elsif match_tokens(Token::Type::URL)
      content = Block.new(Block::Type::LINK, [eat.literal])

    else
      content = eat.escaped_literal
    end

    content
  end

  protected

  def match_tokens (*expected_tokens)
    options = {}
    if expected_tokens.last.kind_of?(Hash)
      options = expected_tokens.pop
    end

    offset = 0
    match = false

    expected_tokens.each do |expected_token_set|
      match = false
      token = @tokenizer.peek(offset)
      puts "\t* Checking #{token.inspect} against #{expected_token_set.inspect}" if $debug
      if options[:skip_whitespace]
        while token && token.type == Token::Type::WHITESPACE
          offset += 1
          token = @tokenizer.peek(offset)
        end
      end

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
    # Skip backwards over whitespace
    offset = -1
    while @tokenizer.peek(offset) &&
        @tokenizer.peek(offset).type == Token::Type::WHITESPACE
      offset -= 1
    end

    # The token before the whitespace must be nil (start of the document) or a
    # newline
    @tokenizer.peek(offset).nil? ||
      @tokenizer.peek(offset).type == Token::Type::NEWLINE
  end

  def ends_line (line_length)
    @tokenizer.peek(line_length).nil? ||
      @tokenizer.peek(line_length).type == Token::Type::NEWLINE
  end

  def end_of_tokens
    @tokenizer.peek.nil?
  end

  def eat_while (token_type)
    next_token = @tokenizer.peek
    eaten = []
    while (next_token && next_token.type == token_type)
      eaten << eat
      next_token = @tokenizer.peek
    end
    eaten
  end

  def eat (token_count = 1)
    token = nil
    token_count.times do
      token = @tokenizer.next_token
    end
    token
  end
end
