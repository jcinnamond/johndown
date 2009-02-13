require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  describe "inline code" do
    it "should convert `` to <code>" do
      string = 'There is `inline code` in this line'
      johndown(string).should ==
        '<p>There is <code>inline code</code> in this line</p>'
    end

    it "should convert `` to <code> even if it begins a line" do
      string = '`code` starts a line'
      johndown(string).should == '<p><code>code</code> starts a line</p>'
    end
  end

  describe "code blocks" do
    it "should convert a block surrounded by :code: to <pre><code>" do
      code = "this is some code"
      string = ":code:\n#{code}\n:code:"
      johndown(string).should == "<pre><code>\n#{code}\n</code></pre>"
    end

    it "should convert a block surrounded by ` on newlines to <pre><code>" do
      code = "this is some code"
      string = "`\n#{code}\n`"
      johndown(string).should == "<pre><code>\n#{code}\n</code></pre>"
    end

    it "should escape charcters inside the code" do
      code = "def something\n puts\"<stuff\"\nend"
      escaped_code = code.gsub('<', '&lt;').gsub('>', '&gt;')
      string = ":code:\n" << code << "\n:code:"
      johndown(string).should == "<pre><code>\n#{escaped_code}\n</code></pre>"
    end

    it "should not try to convert ` within a code block" do
      code = "This is `inline code` within a block"
      string = "`\n#{code}\n`"
      johndown(string).should == "<pre><code>\n#{code}\n</code></pre>"
    end

    it "should not try to convert :code: within a paragraph" do
      string = "This :code: is not :code:"
      johndown(string).should == "<p>#{string}</p>"
    end
  end
end