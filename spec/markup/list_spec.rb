require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  describe "unordered lists" do
    it "should convert - to unordered lists" do
      string = "- A list item\n - And another one\n-and another"
      johndown(string).should ==
        "<ul><li>A list item</li><li>And another one</li>" +
        "<li>and another</li></ul>"
    end

    it "should not convert - in the middle of a line to a list" do
      string = "There is a - in this line"
      johndown(string).should == "<p>#{string}</p>"
    end
  end

  describe "ordered lists" do
    it "should convert lines starting with 1. to an ordered list" do
      string = "1. This is an item\n  1.This is another\n\n1. And yet another"
      johndown(string).should ==
        "<ol><li>This is an item</li><li>This is another</li>" +
        "<li>And yet another</li></ol>"
    end

    it "should not convert a number on its own to a list" do
      string = "This has 1 number"
      johndown(string).should == "<p>#{string}</p>"
    end

    it "should not convert a line starting with 1 on own to a list" do
      string = "1 number in this line"
      johndown(string).should == "<p>#{string}</p>"
    end

    it "should not convert a line starting with 1.4 to a list" do
      string = "1.4 is the latest"
      johndown(string).should == "<p>#{string}</p>"
    end

    it "should not convert a lonely decimal to a list" do
      string = "6.7"
      johndown(string).should == "<p>#{string}</p>"
    end
  end
end