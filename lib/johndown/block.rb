class Block
  module Type
    PARAGRAPH   = 1 << 0
    EM          = 1 << 1
    STRONG      = 1 << 2
    MDASH       = 1 << 3
    BLOCKQUOTE  = 1 << 4
    CITATION    = 1 << 5
    HR          = 1 << 6
    INLINE_CODE = 1 << 7
    CODE_BLOCK  = 1 << 8
    DNF         = 1 << 9
    HEADING     = 1 << 10
    UL          = 1 << 11
    OL          = 1 << 12
    LI          = 1 << 13
    LINK        = 1 << 14
  end

  attr_accessor :type, :content

  def initialize (type, content = nil)
    self.type = type
    self.content = content
  end

  def == (other)
    other.kind_of?(Block) &&
      self.type == other.type &&
      self.content == other.content
  end
end
