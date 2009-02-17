class Generator
  attr_accessor :blocks

  def initialize (blocks)
    self.blocks = blocks
  end

  def html
    html = ''
    blocks.each do |block|
      html << html_paragraph(block)
    end
    html
  end

  protected

  def html_paragraph (block)
    paragraph = "<p>"
    block.content.each do |element|
      if element == "\n"
        paragraph << "<br/>"
      else
        paragraph << element
      end
    end
    paragraph << "</p>"
  end
end
