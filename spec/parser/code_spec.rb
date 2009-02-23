require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "with inline code" do
    before(:each) do
      @parser = Parser.new("A paragraph with `inline code` markup")
      @paragraph = @parser.blocks.first
      @inline_block = @paragraph.content[1]
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should include the code block in the content" do
      @inline_block.should_not be_nil
    end

    it "should set the type of the code block" do
      @inline_block.type.should == Block::Type::INLINE_CODE
    end

    it "should set the content of the code block" do
      @inline_block.content.should == ["inline code"]
    end
  end

  describe "with a block starting with :code:" do
    before(:each) do
      @parser = Parser.new(":code:\nA code block\n:code:")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the type of the code block" do
      @parser.blocks.first.type.should == Block::Type::CODE_BLOCK
    end

    it "should set the content of the code block" do
      @parser.blocks.first.content.should == ["A code block"]
    end

    it "should not try to convert ` inside a code block" do
      parser = Parser.new(":code:\nA code block with ` inside\n:code:")
      parser.blocks.first.content.should == ["A code block with ` inside"]
    end
  end

  describe "with a block starting with `" do
    before(:each) do
      @parser = Parser.new("`\nA code block\n`")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the type of the code block" do
      @parser.blocks.first.type.should == Block::Type::CODE_BLOCK
    end

    it "should set the content of the code block" do
      @parser.blocks.first.content.should == ["A code block"]
    end
  end
end