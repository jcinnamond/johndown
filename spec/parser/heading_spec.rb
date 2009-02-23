require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Parser do
  describe "parsing headings" do
    before(:each) do
      @heading = "A heading"
    end

    describe "(h1)" do
      before(:each) do
        @parser = Parser.new("# #{@heading}")
      end

      it "should only return one block" do
        @parser.blocks.size.should == 1
      end

      it "should return a HEADING block" do
        @parser.blocks.first.type.should == Block::Type::HEADING
      end

      it "should return the heading level and heading text as content" do
        @parser.blocks.first.content.should == [1, @heading]
      end
    end

    describe "(h2)" do
      before(:each) do
        @parser = Parser.new("## #{@heading}")
      end

      it "should only return one block" do
        @parser.blocks.size.should == 1
      end

      it "should return a HEADING block" do
        @parser.blocks.first.type.should == Block::Type::HEADING
      end

      it "should return the heading level and heading text as content" do
        @parser.blocks.first.content.should == [2, @heading]
      end
    end

    describe "(h3-h9)" do
      it "should return the correct heading level" do
        (3..9).each do |level|
          parser = Parser.new('#' * level + "#{@heading}")
          parser.blocks.first.content.should == [level, @heading]
        end
      end
    end
  end
end