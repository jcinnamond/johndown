require File.dirname(__FILE__) + '/../../lib/johndown'
require 'test/unit'

class JohndownTest < Test::Unit::TestCase
  #--------------------------------------------------------------------------
  # Parser test
  #
  # These make sure the parser generates the expected outcome.
  #
  
  def test_paragraph
    paragraph = "This is a paragraph"
    assert_equal("<p>#{paragraph}</p>", Johndown.new(paragraph).to_s)
  end

  def test_multiple_paragraph
    multiple_paragraph = "This is a string\n\nwith multiple paragraphs"
    assert_equal('<p>This is a string</p><p>with multiple paragraphs</p>',
                 Johndown.new(multiple_paragraph).to_s)
  end
  
  def test_line_breaks
    multiple_lines = "This is a string\nwith line breaks"
    assert_equal('<p>This is a string<br/>with line breaks</p>',
                 Johndown.new(multiple_lines).to_s)
  end
  
  def test_italic
    with_italic = 'This is a string with ~italics~'
    assert_equal('<p>This is a string with <em>italics</em></p>',
                 Johndown.new(with_italic).to_s)
  end

  def test_bold
    with_bold = 'This is a string with *bold text*'
    assert_equal('<p>This is a string with <strong>bold text</strong></p>',
                 Johndown.new(with_bold).to_s)
  end

  def test_inline_code
    with_inline_code = 'There is `inline code` in this line'
    assert_equal('<p>There is <code>inline code</code> in this line</p>',
                 Johndown.new(with_inline_code).to_s)

    inline_code_starts_line = "`code` starts a line"
    assert_equal('<p><code>code</code> starts a line</p>',
                 Johndown.new(inline_code_starts_line).to_s)

  end

  def test_headings
    h1 = '# This is a heading'
    assert_equal '<h1>This is a heading</h1>', Johndown.new(h1).to_s

    h2 = '## This is a heading'
    assert_equal '<h2>This is a heading</h2>', Johndown.new(h2).to_s

    h3 = '### This is a heading'
    assert_equal '<h3>This is a heading</h3>', Johndown.new(h3).to_s

    h4 = '#### This is a heading'
    assert_equal '<h4>This is a heading</h4>', Johndown.new(h4).to_s

    h5 = '##### This is a heading'
    assert_equal '<h5>This is a heading</h5>', Johndown.new(h5).to_s

    not_a_heading = 'This is # not a heading'
    assert_equal('<p>' << not_a_heading << '</p>',
                 Johndown.new(not_a_heading).to_s)
  end

  def test_links
    unnamed_link = "Link to http://www.internet/ with some text after"
    assert_equal('<p>Link to ' +
                 '<a href="http://www.internet/">http://www.internet/</a>' +
                 ' with some text after</p>',
                 Johndown.new(unnamed_link).to_s)

    lonely_link = "http://link.to/"
    assert_equal('<p><a href="http://link.to/">http://link.to/</a></p>',
                 Johndown.new(lonely_link).to_s)

    named_link = "Link to (somewhere)http://link.to/"
    assert_equal('<p>Link to <a href="http://link.to/">somewhere</a></p>',
                 Johndown.new(named_link).to_s)

    named_link_with_space = "Link to ( somewhere ) http://link.to/"
    assert_equal('<p>Link to <a href="http://link.to/">somewhere </a></p>',
                 Johndown.new(named_link_with_space).to_s)

    not_a_named_link = "This is (not) a link"
    assert_equal('<p>This is (not) a link</p>',
                 Johndown.new(not_a_named_link).to_s)

    lparen_at_line_start = "Some text\n\n(and an aside)"
    assert_equal('<p>Some text</p><p>(and an aside)</p>',
                 Johndown.new(lparen_at_line_start).to_s)
    
  end

  def test_code
    not_code = "This paragraph contains :code:"
    assert_equal('<p>This paragraph contains :code:</p>',
                 Johndown.new(not_code).to_s)
    
    code = "def something\n puts \"<stuff>\"\nend"
    escaped_code = code.gsub('<', '&lt;').gsub('>', '&gt;')
    string = ":code:\n" << code << "\n:code:"
    assert_equal("<pre><code>\n" << escaped_code << "\n</code></pre>",
                 Johndown.new(string).to_s)

    code_with_backticks = "this is\na code block\nwith`"
    string = "`\n" << code_with_backticks << "\n`"
    assert_equal("<pre><code>\n" << code_with_backticks << "\n</code></pre>",
                 Johndown.new(string).to_s)
  end

  def test_quote
    not_quote = "This paragraph contains :quote:"
    assert_equal('<p>This paragraph contains :quote:</p>',
                 Johndown.new(not_quote).to_s)

    quote = "This is a long quotation from somewhere"
    string = ":quote:\n" << quote << "\n:quote:\n"
    assert_equal("<blockquote><p>" << quote << "</p></blockquote>",
                 Johndown.new(string).to_s)
  end

  def test_dnf
    dnf = "This has literal\nnewlines & unescaped <html> tags\n"
    string = ":dnf:\n" << dnf << ":dnf:"
    assert_equal(dnf, Johndown.new(string).to_s)
  end

  def test_auto_escape
    string = "This has <tags> & a < comparison"
    assert_equal("<p>This has &lt;tags&gt; &amp; a &lt; comparison</p>",
                 Johndown.new(string).to_s)
  end

  def test_numbered_list
    string = "1. This is an item\n  1.This is another\n\n1. And yet another"
    assert_equal("<ol><li> This is an item</li><li>  This is another</li><li> And yet another</li></ol>",
                 Johndown.new(string).to_s)
  end

  def test_numbers_outside_list
    string = "This has 1 number"
    assert_equal("<p>#{string}</p>", Johndown.new(string).to_s)
    
    string_with_decimal = "This has 1.2 decimal numbers"
    assert_equal("<p>#{string_with_decimal}</p>", 
      Johndown.new(string_with_decimal).to_s)
    
    string_starting_with_decimal = "1.4 is the latest"
    assert_equal("<p>#{string_starting_with_decimal}</p>", 
      Johndown.new(string_starting_with_decimal).to_s)
    
    lonely_decimal = "6.7"
    assert_equal("<p>#{lonely_decimal}</p>",
      Johndown.new(lonely_decimal).to_s)
  end

  def test_unordered_list
    string = "- A list item\n - And another one\n-and another"
    assert_equal("<ul><li> A list item</li><li>  And another one</li><li>and another</li></ul>",
                 Johndown.new(string).to_s)
  end

  def test_hr
    string = "-----"
    assert_equal("<hr />", Johndown.new(string).to_s)

    string = "Allow ----- in strings"
    assert_equal("<p>#{string}</p>", Johndown.new(string).to_s)
  end

  def test_escape
    string = "\\*bold\\*"
    assert_equal("<p>*bold*</p>", Johndown.new(string).to_s)
  end
  
  def test_carriage_returns
    string = "line 1\r\n\r\nline 2"
    assert_equal("<p>line 1</p><p>line 2</p>", Johndown.new(string).to_s)
  end

  #--------------------------------------------------------------------------
  # Joined up test. Make sure that all aspects of the markup work.
  #

  def test_full_markup
    input = ''
    full_markup = ''

    # Heading 1
    input << "# This is a heading\n"
    full_markup << '<h1>This is a heading</h1>'

    # Paragraph
    input << "This is a paragraph\n\nWith multiple lines\n\n"
    full_markup << '<p>This is a paragraph</p><p>With multiple lines</p>'

    input << "Here are\nsome line\nbreaks\n\n"
    full_markup << '<p>Here are<br/>some line<br/>breaks</p>'

    # Bold, italics and code
    input << "This paragraph has *bold* and ~italic~ text and `code`\n\n"
    full_markup << '<p>This paragraph has <strong>bold</strong> and ' <<
      '<em>italic</em> text and <code>code</code></p>'

    # Links
    input << "Here is a (link)http://link.to/\n\n"
    full_markup << '<p>Here is a <a href="http://link.to/">link</a></p>'

    assert_equal full_markup, Johndown.new(input).to_s
  end
  
end
