require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should convert an http url into a link" do
    string = "Link to http://www.internet/ with some text after"
    johndown(string).should ==
      '<p>Link to ' +
      '<a href="http://www.internet/">http://www.internet/</a>' +
      ' with some text after</p>'
  end

  it "should convert (name) followed by a url into a link" do
    string = "Link to (somewhere)http://link.to/"
    johndown(string).should ==
      '<p>Link to <a href="http://link.to/">somewhere</a></p>'
  end

  it "should allow spaces when specifying link names" do
    string = "This is a ( link to somewhere ) http://link.to/"
    johndown(string).should ==
      '<p>This is a <a href="http://link.to/">link to somewhere </a></p>'
  end

  it "should cope with links at the start of a paragraph" do
    string = "http://link.to/"
    johndown(string).should ==
      '<p><a href="http://link.to/">http://link.to/</a></p>'
  end

  it "should cope with named links at the start of a paragraph"

  it "should not try to convert (text) into a link if no url is present" do
    string = "This is (not) a link"
    johndown(string).should == "<p>#{string}</p>"
  end

  it "should convert (url) into a link"

  it "should not include characters abutting (url) in the link"
end