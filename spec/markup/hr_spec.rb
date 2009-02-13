require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should convert ----- on a line on its own to <hr />" do
    string = "-----"
    johndown(string).should == "<hr />"
  end

  it "should not convert ----- in a paragraph to <hr/>" do
    string = "This has ----- some dashes"
    johndown(string).should == "<p>#{string}</p>"
  end
end