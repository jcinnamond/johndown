require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "with italics" do
    before(:each) do
      @parser = Parser.new("A paragraph with ~inline~ markup")
      @paragraph = @parser.blocks.first
      @inline_block = @paragraph.content[1]
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should include the italic block in the content" do
      @inline_block.should_not be_nil
    end

    it "should set the type of the italic block" do
      @inline_block.type.should == Block::Type::EM
    end

    it "should set the content of the italic block" do
      @inline_block.content.should == ["inline"]
    end
  end

  describe "with bold" do
    before(:each) do
      @parser = Parser.new("A paragraph with *inline* markup")
      @paragraph = @parser.blocks.first
      @inline_block = @paragraph.content[1]
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should include the italic block in the content" do
      @inline_block.should_not be_nil
    end

    it "should set the type of the italic block" do
      @inline_block.type.should == Block::Type::STRONG
    end

    it "should set the content of the italic block" do
      @inline_block.content.should == ["inline"]
    end
  end

  describe "with --" do
    before(:each) do
      @parser = Parser.new("A paragraph with -- a dash")
      @paragraph = @parser.blocks.first
      @inline_block = @paragraph.content[1]
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should include the italic block in the content" do
      @inline_block.should_not be_nil
    end

    it "should set the type of the italic block" do
      @inline_block.type.should == Block::Type::MDASH
    end

    it "should set the content of the italic block" do
      @inline_block.content.should be_nil
    end
  end

  describe "with -" do
    before(:each) do
      @parser = Parser.new("A paragraph with - a single dash")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the paragraph contents" do
      @parser.blocks.first.content.should == 
        ["A paragraph with - a single dash"]
    end
  end
end