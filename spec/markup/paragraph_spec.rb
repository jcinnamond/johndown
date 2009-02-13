require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should convert strings into paragraphs" do
    string = "This is a paragraph"
    johndown(string).should == "<p>#{string}</p>"
  end

  it "should create multiple paragraphs from double newlines" do
    line1 = "This is a paragraph"
    line2 = "with multiple paragraphs"
    string = "#{line1}\n\n#{line2}"
    johndown(string).should == "<p>#{line1}</p><p>#{line2}</p>"
  end

  it "should recognise \r\n as a newline" do
    line1 = "This is a paragraph"
    line2 = "with multiple paragraphs"
    string = "#{line1}\r\n\r\n#{line2}"
    johndown(string).should == "<p>#{line1}</p><p>#{line2}</p>"
  end

  it "should remove excess newlines" do
    line1 = "This is a paragraph"
    line2 = "with multiple paragraphs"
    string = "#{line1}\n\n\n\n#{line2}"
    johndown(string).should == "<p>#{line1}</p><p>#{line2}</p>"
  end

  it "should convert single newlines within blocks of text into <br>s" do
    line1 = "This is a paragraph"
    line2 = "with line_breaks"
    string = "#{line1}\n#{line2}"
    johndown(string).should == "<p>#{line1}<br/>#{line2}</p>"
  end
end
