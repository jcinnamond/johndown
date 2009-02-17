require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Block do
  it "should return the Block type" do
    block = Block.new(Block::Type::PARAGRAPH)
    block.type.should == Block::Type::PARAGRAPH
  end

  it "should return the block content" do
    content = "This is some content"
    block = Block.new(Block::Type::PARAGRAPH, content)
    block.content.should == content
  end
end