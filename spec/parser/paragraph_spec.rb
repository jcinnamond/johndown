require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "parsing strings as paragraphs" do
    before(:each) do
      @parser = Parser.new('some paragraph')
    end

    it "should only return one block" do
      @parser.blocks.size.should == 1
    end

    it "should return a paragraph" do
      @parser.blocks.first.type.should == Block::Type::PARAGRAPH
    end

    it "should return the paragraph content" do
      @parser.blocks.first.content.should == ["some paragraph"]
    end
  end

  describe "parsing multiple strings as multiple paragraphs" do
    before(:each) do
      @parser = Parser.new("some paragraph\n\nsome other paragraph")
    end

    it "should return two blocks" do
      @parser.blocks.size.should == 2
    end

    it "should return two paragraphs" do
      @parser.blocks.each do |block|
        block.type.should == Block::Type::PARAGRAPH
      end
    end

    it "should correctly set the contents of the first paragraph" do
      @parser.blocks.first.content.should == ["some paragraph"]
    end

    it "should correctly set the contents of the second paragraph" do
      @parser.blocks.last.content.should == ["some other paragraph"]
    end
  end

  describe "parsing newlines within paragraphs" do
    before(:each) do
      @parser = Parser.new("first line\nsecond line")
    end

    it "should return only one block" do
      @parser.blocks.size.should == 1
    end

    it "should return the two strings and a newline as content" do
      @parser.blocks.first.content.should ==   ["first line", "\n", "second line"]
    end
  end

  describe "ignoring excessive newlines" do
    before(:each) do
      @parser = Parser.new("\nsome paragraph\n\n\nsome other paragraph\n\n\n")
    end

    it "should return two blocks" do
      @parser.blocks.size.should == 2
    end

    it "should return two paragraphs" do
      @parser.blocks.each do |block|
        block.type.should == Block::Type::PARAGRAPH
      end
    end

    it "should correctly set the contents of the first paragraph" do
      @parser.blocks.first.content.should == ["some paragraph"]
    end

    it "should correctly set the contents of the second paragraph" do
      @parser.blocks.last.content.should == ["some other paragraph"]
    end
  end
end