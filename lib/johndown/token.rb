class Token

  module Type
    NEWLINE      = 1 << 0
    TILDE        = 1 << 1
    ASTERISK     = 1 << 2
    HASH         = 1 << 3
    LPAREN       = 1 << 4
    RPAREN       = 1 << 5
    BACKTICK     = 1 << 6
    URL          = 1 << 7
    STRING       = 1 << 8
    CODE_BLOCK   = 1 << 9
    QUOTE_BLOCK  = 1 << 10
    DNF_BLOCK    = 1 << 11
    LESS_THAN    = 1 << 12
    GREATER_THAN = 1 << 13
    AMPERSAND    = 1 << 14
    DIGIT        = 1 << 15
    PERIOD       = 1 << 16
    WHITESPACE   = 1 << 17
    DASH         = 1 << 18
    LITERAL      = 1 << 19
  end

  LITERALS = {
    Type::NEWLINE      => "\n",
    Type::TILDE        => '~',
    Type::ASTERISK     => '*',
    Type::HASH         => '#',
    Type::LPAREN       => '(',
    Type::RPAREN       => ')',
    Type::BACKTICK     => '`',
    Type::CODE_BLOCK   => ':code:',
    Type::QUOTE_BLOCK  => ':quote:',
    Type::LESS_THAN    => '<',
    Type::GREATER_THAN => '>',
    Type::AMPERSAND    => '&',
    Type::DNF_BLOCK    => ':dnf:',
    Type::PERIOD       => '.',
    Type::DASH         => '-'
  }

  ESCAPED_LITERALS = {
    Type::LESS_THAN    => '&lt;',
    Type::GREATER_THAN => '&gt;',
    Type::AMPERSAND    => '&amp;'
  }
  
  attr_reader :type
  attr_accessor :content
  
  def initialize (type, content = nil)
    @type = type
    @content = content

    if @type == Type::STRING || @type == Type::WHITESPACE
      @content ||= ''
    end
  end

  def literal
    return self.content.to_s if @content
    
    LITERALS[@type]
  end

  def escaped_literal
    return ESCAPED_LITERALS[@type] if ESCAPED_LITERALS[@type]
    literal
  end
end
