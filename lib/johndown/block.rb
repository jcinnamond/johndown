class Block
  module Type
    PARAGRAPH = 1 << 0
  end

  attr_accessor :type, :content

  def initialize (type, content = nil)
    self.type = type
    self.content = content
  end
end
