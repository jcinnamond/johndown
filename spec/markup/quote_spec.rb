require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should convert text surrounded by :quote: to <blockquote>" do
    quote = "This is a long quotation from somewhere"
    string = ":quote:\n#{quote}\n:quote:"
    johndown(string).should == "<blockquote><p>#{quote}</p></blockquote>"
  end

  it "should not convert :quote: in the middle of a paragraph to a blockquote" do
    string = "This paragraph contains :quote:"
    johndown(string).should == "<p>#{string}</p>"
  end

  it "should convert -- within :quote: into a citation"
end