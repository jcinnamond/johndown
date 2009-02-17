require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Generator do
  describe "paragraphs" do
    it "should wrap paragraphs in <p>...</p>" do
      @generator = Generator.new(
        [
          Block.new(Block::Type::PARAGRAPH, ["some paragraph"])
        ]
      )
      @generator.html.should == "<p>some paragraph</p>"
    end

    it "should replace newlines in paragraphs with <br/>" do
      @generator = Generator.new(
        [
          Block.new(
            Block::Type::PARAGRAPH,
            ["first line", "\n", "second line"]
          )
        ]
      )
      @generator.html.should == "<p>first line<br/>second line</p>"

    end
  end

end