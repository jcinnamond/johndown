require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "parsing unordered lists" do
    before(:each) do
      @parser = Parser.new("- item1\n - item2\n-items 3-5")
      @content = @parser.blocks.first.content
    end

    it "should only return one block" do
      @parser.blocks.size.should == 1
    end

    it "should return a UL block" do
      @parser.blocks.first.type.should == Block::Type::UL
    end

    it "should return a content item for each list item" do
      @content.size.should == 3
    end

    it "should return an array of LI blocks" do
      @content.each do |item|
        item.should be_kind_of(Block)
        item.type.should == Block::Type::LI
      end
    end

    it "should set the content of each LI block" do
      @content[0].content.should == ["item1"]
      @content[1].content.should == ["item2"]
      @content[2].content.should == ["items 3-5"]
    end
  end

  describe "parsing ordered lists" do
    before(:each) do
      @parser = Parser.new("1. item1\n 1. item 2.2\n\n1. items 3-5")
      @content = @parser.blocks.first.content
    end

    it "should only return one block" do
      @parser.blocks.size.should == 1
    end

    it "should return a UL block" do
      @parser.blocks.first.type.should == Block::Type::OL
    end

    it "should return a content item for each list item" do
      @content.size.should == 3
    end

    it "should return an array of LI blocks" do
      @content.each do |item|
        item.should be_kind_of(Block)
        item.type.should == Block::Type::LI
      end
    end

    it "should set the content of each LI block" do
      @content[0].content.should == ["item1"]
      @content[1].content.should == ["item 2.2"]
      @content[2].content.should == ["items 3-5"]
    end

    it "should not convert a decimal number at the start of a line to an Ol" do
      parser = Parser.new("1.4 item1")
      parser.blocks.first.type.should == Block::Type::PARAGRAPH
    end
  end
end