class Generator
  attr_accessor :blocks

  def initialize (blocks)
    self.blocks = blocks
  end

  def html
    html = ''
    blocks.each do |block|
      html << generate(block)
    end
    html
  end

  protected

  def generate (block)
    case block.type
    when Block::Type::PARAGRAPH
      wrap(block, :p)
    when Block::Type::EM
      wrap(block, :em)
    when Block::Type::STRONG
      wrap(block, :strong)
    when Block::Type::MDASH
      "&mdash;"
    else
      raise "Don't know how to generate #{block.inspect}"
    end
  end


  def wrap (block, tag)
    content = "<#{tag}>"
    block.content.each do |element|
      if element.kind_of?(Block)
        content << generate(element)
      elsif element == "\n"
        content << "<br/>"
      else
        content << element
      end
    end
    content << "</#{tag}>"
  end
end
