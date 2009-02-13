require File.join(File.dirname(__FILE__), 'markup_helper.rb')

describe Johndown do
  it "should convert a complete block of text properly" do
    input = ''
    markup = ''

    # Test headings and an initial paragraph
    heading = "A test document"
    paragraph = 'The purpose of this is to test headings and paragraphs'
    input << "# #{heading}\r\n\r\n#{paragraph}\r\n\r\n"
    markup << "<h1>#{heading}</h1><p>#{paragraph}</p>"

    # Test headings followed by a quote
    heading = "A heading before a quote"
    quote = "A quotation"
    input << "## #{heading}\r\n\r\n:quote:\r\n#{quote}\r\n:quote:\r\n"
    markup << "<h2>#{heading}</h2><blockquote><p>#{quote}</p></blockquote>"

    johndown(input).should == markup
  end
end