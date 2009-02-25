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
    when Block::Type::BLOCKQUOTE
      blockquote(block)
    when Block::Type::HR
      "<hr/>"
    when Block::Type::INLINE_CODE
      wrap(block, :code)
    when Block::Type::CODE_BLOCK
      code_block(block)
    when Block::Type::DNF
      block.content.join
    when Block::Type::HEADING
      heading(block)
    when Block::Type::UL
      list(block, :ul)
    when Block::Type::OL
      list(block, :ol)
    else
      raise "Don't know how to generate #{block.inspect}"
    end
  end

  def blockquote (block)
    content = "<blockquote>"

    block.content.each do |element|
      if element.kind_of?(String)
        content << "<p>#{element}</p>"
      elsif element.kind_of?(Block) && element.type == Block::Type::CITATION
        content << wrap(element, :cite)
      else
        content << generate(element)
      end
    end

    content << "</blockquote>"
  end

  def code_block (block)
    content = "<pre><code>\n"
    block.content.each do |element|
      if element.kind_of?(Block)
        content << generate(element)
      else
        content << element
      end
    end
    content << "\n</code></pre>"
  end

  def heading (block)
    level = block.content.shift
    content = "<h#{level}>"

    block.content.each do |element|
      if element.kind_of?(Block)
        content << generate(element)
      else
        content << element
      end
    end

    content << "</h#{level}>"
  end

  def list (block, tag)
    content = "<#{tag}>"
    block.content.inject(content) do |list, list_item|
      list << wrap(list_item, :li)
    end
    content << "</#{tag}>"
  end

  def wrap (block, *tags)
    content = tags.inject("") { |str, tag| str << "<#{tag}>"}

    block.content.each do |element|
      if element.kind_of?(Block)
        content << generate(element)
      elsif element == "\n"
        content << "<br/>"
      else
        content << element
      end
    end
    content << tags.reverse.inject("") { |str, tag| str << "</#{tag}>"}
  end
end
