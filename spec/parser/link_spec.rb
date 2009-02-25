require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "parsing unnamed links" do
    before(:each) do
      @url = "http://www.cinnamond.me.uk/"
      @parser = Parser.new(@url)
      @link_block = @parser.blocks.first.content.first
    end

    it "should only return one block" do
      @parser.blocks.size.should == 1
    end

    it "should return a top level paragraph block" do
      @parser.blocks.first.type.should == Block::Type::PARAGRAPH
    end

    it "should return one content element" do
      @parser.blocks.first.content.size.should == 1
    end

    it "should return a LINK block as the content" do
      @link_block.type.should == Block::Type::LINK
    end

    it "should return the link as the LINK block content" do
      @link_block.content.should == [@url]
    end
  end

  describe "parsing named links" do
    before(:each) do
      @url = "http://www.cinnamond.me.uk/"
      @name = "my blog"
      @parser = Parser.new("(my blog) #{@url}")
      @link_block = @parser.blocks.first.content.first
    end

    it "should only return one block" do
      @parser.blocks.size.should == 1
    end

    it "should return a top level paragraph block" do
      @parser.blocks.first.type.should == Block::Type::PARAGRAPH
    end

    it "should return one content element" do
      @parser.blocks.first.content.size.should == 1
    end

    it "should return a LINK block as the content" do
      @link_block.type.should == Block::Type::LINK
    end

    it "should return the name and link as the LINK block content" do
      @link_block.content.should == [@name, @url]
    end

  end
end