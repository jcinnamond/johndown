require File.join(File.dirname(__FILE__), 'block')

class Parser
  def initialize(string)
    @tokenizer = Tokenizer.new
    @tokenizer.scan(string)
  end

  def blocks
    parse_top_level_blocks
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
        blocks << block if block
      end
      
      loop_count += 1
      raise "Infinite parsing loop. Parser is broken" if loop_count > limit
    end
    blocks
  end

  def parse_paragraph
    content = []
    in_paragraph = true

    while in_paragraph
      if match_tokens(nil)
        in_paragraph = false

      elsif match_tokens(Token::Type::NEWLINE, Token::Type::NEWLINE)
        eat(2)
        in_paragraph = false

      elsif match_tokens(Token::Type::NEWLINE)
        content << eat.literal

      elsif match_tokens(Token::Type::STRING)
        content << eat.content
      end
    end

    Block.new(Block::Type::PARAGRAPH, content)
  end

  protected

  def match_tokens (*expected_tokens)
    offset = 0
    match = false

    expected_tokens.each do |expected_token|
      token = @tokenizer.peek(offset)
      
      if (token && token.type == expected_token) or
          (token.nil? && expected_token.nil?)
        match = true
      else
        return false
      end

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
