require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "quotations" do
    before(:each) do
      @parser = Parser.new(":quote:\nA quotation\n:quote:")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the type of the block to blockquote" do
      @parser.blocks.first.type.should == Block::Type::BLOCKQUOTE
    end

    it "should set the content of the block" do
      @parser.blocks.first.content.should == ["A quotation"]
    end
  end

  describe "quotations with citations" do
    before(:each) do
      @parser = Parser.new(":quote:\nA quotation\n-- with a citation\n:quote:")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the type of the block to blockquote" do
      @parser.blocks.first.type.should == Block::Type::BLOCKQUOTE
    end

    it "should include the citation block in the content" do
      @parser.blocks.first.content.should ==
        ["A quotation", Block.new(Block::Type::CITATION, ["with a citation"])]
    end
  end

  describe ":quote: appearing in a line" do
    before(:each) do
      @parser = Parser.new("A paragraph containing :quote:\n")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the block type to paragraph" do
      @parser.blocks.first.type.should == Block::Type::PARAGRAPH
    end

    it "should use the literal value for :quote:" do
      @parser.blocks.first.content.should ==
        ["A paragraph containing :quote:"]
    end
  end
end