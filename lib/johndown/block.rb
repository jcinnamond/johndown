class Block
  module Type
    PARAGRAPH  = 1 << 0
    EM         = 1 << 1
    STRONG     = 1 << 2
    MDASH      = 1 << 3
    BLOCKQUOTE = 1 << 4
    CITATION   = 1 << 5
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
