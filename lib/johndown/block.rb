class Block
  module Type
    PARAGRAPH = 1 << 0
    EM        = 1 << 1
    STRONG    = 1 << 2
    MDASH     = 1 << 3
  end

  attr_accessor :type, :content

  def initialize (type, content = nil)
    self.type = type
    self.content = content
  end
end
