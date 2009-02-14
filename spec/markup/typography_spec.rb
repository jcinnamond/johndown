require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should convert ~~ into <em>" do
    string = 'This is a string with ~italics~'
    johndown(string).should == '<p>This is a string with <em>italics</em></p>'
  end

  it "should convert ** into <strong>" do
    string = 'This is a string with *bold text*'
    johndown(string).should ==
      '<p>This is a string with <strong>bold text</strong></p>'
  end

  it "should convert -- to &mdash;" do
    string = 'This is a string -- with a dash'
    johndown(string).should ==
      '<p>This is a string &mdash; with a dash</p>'
  end
end