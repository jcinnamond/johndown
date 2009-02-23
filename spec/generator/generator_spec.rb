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


  describe "quotes" do
    it "should wrap BLOCKQUOTE with <blockquote><p>...</p></blockquote>" do
      @generator = Generator.new(
        [Block.new(Block::Type::BLOCKQUOTE, ["some quote"])]
      )
      @generator.html.should == "<blockquote><p>some quote</p></blockquote>"
    end

    it "should convert a CITATION within a BLOCKQUOTE to <cite>...</cite>" do
      @generator = Generator.new(
        [Block.new(Block::Type::BLOCKQUOTE, [
              "some quote",
              Block.new(Block::Type::CITATION, ["citation"])
            ])]
      )
      @generator.html.should ==
        "<blockquote><p>some quote</p><cite>citation</cite></blockquote>"
    end
  end

  describe "hr" do
    it "should convert HR to <hr/>" do
      @generator = Generator.new(
        [Block.new(Block::Type::HR, [])]
      )
      @generator.html.should == "<hr/>"
    end
  end

  describe "inline code" do
    it "should convert INLINE_CODE to <code>...</code>" do
      @generator = Generator.new(
        [Block.new(Block::Type::INLINE_CODE, ["inline code"])]
      )
      @generator.html.should == "<code>inline code</code>"
    end
  end

  describe "code block" do
    it "should convert CODE_BLOCK to <pre><code>...</code></pre>" do
      @generator = Generator.new(
        [Block.new(Block::Type::CODE_BLOCK, ["code block"])]
      )
      @generator.html.should == "<pre><code>\ncode block\n</code></pre>"
    end
  end
end