require 'strscan'
require File.dirname(__FILE__) + '/token'

class Tokenizer
  def initialize
    @scanner = StringScanner.new('')
    @tokens = Array.new
    @pos = 0
  end

  def scan (string)
    @scanner = @scanner.concat(string)
    tokenize
  end

  def next_token
    token = @tokens[@pos]
    @pos += 1
    token
  end

  def previous_token
    # @pos points to the next token to return, not the current token,
    # so the previous token will be two behind
    return nil if @pos < 2
    @tokens[@pos - 2]
  end

  def peek (offset = 0)
    if @pos + offset < 0
      nil
    else
      @tokens[@pos + offset]
    end
  end

  def tokens
    if block_given?
      while @pos < @tokens.length
        t = next_token
        yield(t)
      end
    else
      @tokens
    end
  end

  private

  def tokenize
    until @scanner.eos?
      chr = @scanner.getch
      case chr
        
      when "\r"
        if @scanner.peek(1) != "\n"
          @tokens << Token.new(Token::Type::WHITESPACE, chr)
        else
          # eat it
        end
        
      when "\\"
        save
        next_chr = @scanner.getch || ''
        @tokens << Token.new(Token::Type::LITERAL, next_chr)

      when 'h'
        if @scanner.peek(6) == 'ttp://'
          save
          @tokens << Token.new(Token::Type::URL,
                               'h' + @scanner.scan(/[^\s|$]+/))
        else
          store(chr)
        end

      when ':'
        tokenized = false

        s = @scanner.check_until(/:/)
        if s == "code:"
          # Eat the block command
          @scanner.scan_until(/:/)
          
          # Tokenize
          add(Token::Type::CODE_BLOCK)
          tokenized = true

        elsif s == "quote:"
          # Eat the block command
          @scanner.scan_until(/:/)
          
          # Tokenize
          add(Token::Type::QUOTE_BLOCK)
          tokenized = true
          
        elsif s == "dnf:"
          # Eat the block command
          @scanner.scan_until(/:/)
          
          # Tokenize
          add(Token::Type::DNF_BLOCK)
          tokenized = true
        end
        
        store(chr) unless tokenized

      when "\n"
        add(Token::Type::NEWLINE)

      when '('
        add(Token::Type::LPAREN)

      when ')'
        add(Token::Type::RPAREN)

      when '~'
        add(Token::Type::TILDE)
      
      when '*'
        add(Token::Type::ASTERISK)
      
      when '`'
        add(Token::Type::BACKTICK)

      when '#'
        add(Token::Type::HASH)

      when '<'
        add(Token::Type::LESS_THAN)
      
      when '>'
        add(Token::Type::GREATER_THAN)
      
      when '&'
        add(Token::Type::AMPERSAND)
      
      when '.'
        add(Token::Type::PERIOD)

      when '-'
        add(Token::Type::DASH)

      when /\d/
        add(Token::Type::DIGIT, chr.to_i)
      
      else
        store(chr)
      end
    end

    # If we were part way through tokenizing something when the document
    # ended, make sure it is added to the array of tokens
    save
  end

  def save
    @tokens << @current_token if @current_token
    @current_token = nil
  end


  def store (chr)
    if chr == ' ' or chr == "\t"
      @current_token ||= Token.new(Token::Type::WHITESPACE)
      @current_token.content << chr
    else
      if @current_token && @current_token.type == Token::Type::WHITESPACE
        save
      end
      
      @current_token ||= Token.new(Token::Type::STRING)
      @current_token.content << chr
    end
  end

  def add (type, content = nil)
    save
    @tokens << Token.new(type, content)
  end

end
