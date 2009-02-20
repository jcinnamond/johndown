require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "with ---" do
    before(:each) do
      @parser = Parser.new("---")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the block type to HR" do
      @parser.blocks.first.type.should == Block::Type::HR
    end

    it "should not set any block contents" do
      @parser.blocks.first.content.should be_empty
    end
  end

  describe "with ----" do
    before(:each) do
      @parser = Parser.new("----")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the block type to HR" do
      @parser.blocks.first.type.should == Block::Type::HR
    end

    it "should not set any block contents" do
      @parser.blocks.first.content.should be_empty
    end
  end

  describe "with -----" do
    before(:each) do
      @parser = Parser.new("-----")
    end

    it "should return one top level block" do
      @parser.blocks.size.should == 1
    end

    it "should set the block type to HR" do
      @parser.blocks.first.type.should == Block::Type::HR
    end

    it "should not set any block contents" do
      @parser.blocks.first.content.should be_empty
    end
  end
end