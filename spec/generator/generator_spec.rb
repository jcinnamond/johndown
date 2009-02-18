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

  describe "inline" do
    it "should wrap EM with <em>..</em>" do
      @generator = Generator.new(
        [
          Block.new(Block::Type::EM, ["some paragraph"])
        ]
      )
      @generator.html.should == "<em>some paragraph</em>"
    end

    it "should wrap STRONG with <strong>..</strong>" do
      @generator = Generator.new(
        [
          Block.new(Block::Type::STRONG, ["some paragraph"])
        ]
      )
      @generator.html.should == "<strong>some paragraph</strong>"
    end

    it "should replace MDASH with &mdash;" do
      @generator = Generator.new([Block.new(Block::Type::MDASH)])
      @generator.html.should == "&mdash;"
    end
  end

end