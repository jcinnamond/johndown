require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should not try to markup text surrounded by :dnf:" do
    dnf = "This has literal\nnewlines & unescaped <html> tags"
    string = ":dnf:\n" << dnf << "\n:dnf:"
    johndown(string).should == dnf
  end

  it "should automatically escape <tag>" do
    string = 'This has a <tag>'
    johndown(string).should == "<p>This has a &lt;tag&gt;</p>"
  end

  it "should automatically escape &" do
    string = 'Escaping is easy & funky'
    johndown(string).should == "<p>Escaping is easy &amp; funky</p>"
  end

  it "should not mark up individual characters preceeded by backslashes" do
    string = '\*not bold\*'
    johndown(string).should == "<p>*not bold*</p>"
  end
end