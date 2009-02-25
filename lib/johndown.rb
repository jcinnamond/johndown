require File.dirname(__FILE__) + '/johndown/tokenizer'
require File.dirname(__FILE__) + '/johndown/parser'
require File.dirname(__FILE__) + '/johndown/generator'

class Johndown
  def initialize (string)
    format(string)
  end

  def to_s
    @formatted_text
  end

  private

  def format (string)
    parser = Parser.new(string)
    generator = Generator.new(parser.blocks)

    @formatted_text = generator.html
  end
end
