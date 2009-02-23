require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "parsing :dnf: blocks" do
    before(:each) do
      @parser = Parser.new(":dnf:\nsome paragraph\n:dnf:")
    end

    it "should only return one block" do
      @parser.blocks.size.should == 1
    end

    it "should return a DNF block" do
      @parser.blocks.first.type.should == Block::Type::DNF
    end

    it "should return the dnf content" do
      @parser.blocks.first.content.should == ["some paragraph"]
    end

    it "should not escape characters" do
      content = "this has <em>emphasised</em> text"
      parser = Parser.new(":dnf:\n#{content}\n:dnf:")
      parser.blocks.first.content.should == [content]
    end
  end
end