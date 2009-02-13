require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should convert # to h1" do
    string = "# A heading"
    johndown(string).should == '<h1>A heading</h1>'
  end

  it "should convert ## to h2" do
    string = "## A heading"
    johndown(string).should == '<h2>A heading</h2>'
  end

  it "should convert ### to h3" do
    string = "### A heading"
    johndown(string).should == '<h3>A heading</h3>'
  end

  it "should convert #### to h4" do
    string = "#### A heading"
    johndown(string).should == '<h4>A heading</h4>'
  end

  it "should convert ##### to h5" do
    string = "##### A heading"
    johndown(string).should == '<h5>A heading</h5>'
  end
end