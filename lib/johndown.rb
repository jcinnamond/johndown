require File.dirname(__FILE__) + '/johndown/tokenizer'
require File.dirname(__FILE__) + '/johndown/parser'
require File.dirname(__FILE__) + '/johndown/generator'

class Johndown
  def initialize (string)
    format(string)
  end

  def to_s
    @formatted_text
  end

  private

  def format (string)
    parser = Parser.new(string)
    generator = Generator.new(parser.blocks)

    @formatted_text = generator.html
  end

  def old_format (string)
    @tokenizer = Tokenizer.new
    @tokenizer.scan(string)

    @formatted_text = ''

    # Keep track of the tags that we have opened and are awaiting closure
    @open_tags = Array.new

    # Track being in a list
    @list = nil

    # Track being part of a heading
    @heading = nil
    
    @tokenizer.tokens do |token|
      case token.type

      when Token::Type::NEWLINE
        if @heading
          @formatted_text << "</#{@heading}>"
          @open_tags.delete(@heading.to_sym)
          @heading = nil

        elsif @list
          if (look_ahead(Token::Type::NEWLINE) &&
                ! look_ahead(Token::Type::NEWLINE,
                Token::Type::DIGIT,
                Token::Type::PERIOD))
            close(:li)
            close(@list)
            @list = nil
          else
            close(:li)
          end
          
        elsif @open_tags.include?(:p) &&
            look_ahead([Token::Type::NEWLINE, Token::Type::QUOTE_BLOCK])
          # Eat the next newline
          eat(Token::Type::NEWLINE)
          
          @formatted_text << '</p>'
          @open_tags.delete(:p)
          
        elsif @open_tags.include?(:p) && ! look_ahead([nil])
          @formatted_text << '<br/>'
        end

      when Token::Type::CODE_BLOCK
        if whole_line
          format_code(Token::Type::CODE_BLOCK)
          
        else
          @formatted_text << token.literal
        end

      when Token::Type::DNF_BLOCK
        if whole_line
          format_dnf
          
        else
          @formatted_text << token.literal
        end

      when Token::Type::QUOTE_BLOCK
        if whole_line
          eat Token::Type::NEWLINE
          balance(:blockquote, false)
        else
          @formatted_text << token.literal
        end

      when Token::Type::HASH
        if starts_line
          heading_level = 1
          while eat(Token::Type::HASH)
            heading_level += 1
          end
          
          @heading = "h#{heading_level}"
          @formatted_text << "<#{@heading}>"
          @open_tags << @heading.to_sym
        else
          @formatted_text << token.literal
        end

        # Simple inline markup
      when Token::Type::TILDE
        balance(:em)
        
      when Token::Type::ASTERISK
        balance(:strong)

      when Token::Type::BACKTICK
        if whole_line
          format_code(Token::Type::BACKTICK)
        else
          balance(:code)
        end

        # Links
      when Token::Type::LPAREN
        if look_ahead(Token::Type::STRING, Token::Type::RPAREN,
            Token::Type::URL)
          eat(Token::Type::WHITESPACE)
          link_text = @tokenizer.next_token
          eat(Token::Type::WHITESPACE)
          ignore_closing = @tokenizer.next_token
          eat(Token::Type::WHITESPACE)
          url = @tokenizer.next_token
          @formatted_text << '<a href="' << url.content.strip << '">' <<
            link_text.content << '</a>'
          
        else
          add_to_paragraph token
        end

      when Token::Type::RPAREN
        @formatted_text << token.literal

      when Token::Type::URL
        add_paragraph = ! @open_tags.include?(:p)

        if add_paragraph
          @formatted_text << '<p>'
        end
        
        @formatted_text << '<a href="' << token.content.strip << '">' <<
          token.content << '</a>'

        next_token = @tokenizer.peek
        if add_paragraph && (next_token.nil? ||
              next_token.type == Token::Type::NEWLINE)
          @formatted_text << '</p>'
        end

        # Lists
      when Token::Type::DIGIT
        skip_whitespace = ! @list.nil?
        if starts_line && 
            look_ahead(Token::Type::PERIOD, 
            Token::Type::WHITESPACE,
            :skip_whitespace => skip_whitespace)
          eat(Token::Type::PERIOD)
          
          unless @list
            @list = :ol
            @formatted_text << '<ol>'
            @open_tags << :ol
          end
          
        else
          add_to_paragraph token
        end

      when Token::Type::DASH
        if starts_line
          if look_ahead(Token::Type::DASH)
            # Check to see if this is a line of at least three dashes
            dash_count = 1
            while eat(Token::Type::DASH)
              dash_count += 1
            end

            if dash_count > 3 &&
                @tokenizer.peek.nil? ||
                @tokenizer.peek.type == Token::Type::NEWLINE
              @formatted_text << '<hr />'
            else
              @formatted_text << '-' * dash_count
            end
          else
            # Single dashes represent lists
            unless @list
              @list = :ul
              @formatted_text << '<ul>'
              @open_tags << :ul
            end

          end
          
        elsif
          dash_count = 1
          while eat(Token::Type::DASH)
            dash_count += 1
          end

          if dash_count == 2 && starts_line &&
              @open_tags.include?(:blockquote)
            @formatted_text << '<cite>'
            @open_tags << :cite
          elsif dash_count == 2 &&
                @tokenizer.peek.type == Token::Type::WHITESPACE
              add_to_paragraph('&mdash;')
          else
            add_to_paragraph token.literal * dash_count
          end
        end

      when Token::Type::LITERAL
        add_to_paragraph token

        # Default paragraph handling
      when Token::Type::STRING
        if @heading
          @formatted_text << token.content.strip
        else
          add_to_paragraph token
        end
        
      else
        if @heading
          @formatted_text << token.content.strip if token.content
        else
          add_to_paragraph token
        end
      end
    end

    # Close any open tags when we reach the end of the document
    @open_tags.reverse.each do |tag|
      @formatted_text << '</' << tag.to_s << '>'
    end
  end

  def close (tag)
    if @open_tags.include?(tag)
      @formatted_text << "</#{tag}>"
      @open_tags.delete(tag)
    end
  end

  def balance (tag, inline = true)
    if @open_tags.include?(tag)
      if inline
        add_to_paragraph "</#{tag}>"
      else
        @formatted_text << "</#{tag}>"
      end
      @open_tags.delete(tag)
      
    else
      if inline
        add_to_paragraph "<#{tag}>"
      else
        @formatted_text << "<#{tag}>"
      end
      @open_tags << tag
    end
  end

  def add_to_paragraph (content)
    sym = :p

    if @list
      sym = :li
    end
      
    unless @open_tags.include?(sym)
      @formatted_text << "<#{sym}>"
      @open_tags << sym
    end

    if content.kind_of?(Token)
      @formatted_text << content.escaped_literal
    else
      @formatted_text << content
    end
  end

  def format_code (closing_type)
    @formatted_text << '<pre><code>'
    token = @tokenizer.next_token
    in_block = true
    
    while token && in_block
      if token.type == closing_type && whole_line
        in_block = false
      else
        @formatted_text << token.escaped_literal
        token = @tokenizer.next_token
      end
    end
    @formatted_text << '</code></pre>'
  end

  def format_dnf
    eat Token::Type::NEWLINE
    token = @tokenizer.next_token
    while token && token.type != Token::Type::DNF_BLOCK
      @formatted_text << token.literal
      token = @tokenizer.next_token
    end
  end

  def look_back (*tags)
    match = false
    
    if tags.kind_of?(Array)
      tags.each do |type|
        tag = @tokenizer.previous_token
        if type.nil?
          match = true if tag.nil?
        elsif ! tag.nil?
          match = true if tag.type == type
        end
      end
      
    else
      tag = @tokenizer.previous_token
      if tag
        match = true if tag.type == tag_set
      end
    end

    return match
  end
  
  def look_ahead (*tags)
    offset = 0
    
    options = { :skip_whitespace => true }
    if tags.size > 1 && tags.last.kind_of?(Hash)
      options.merge! tags.pop
    end
    
    tags.each do |tag_set|
      next if tag_set == Token::Type::WHITESPACE && options[:skip_whitespace]
      
      match = false
      
      if tag_set.kind_of?(Array)
        tag_set.each do |type|
          tag = @tokenizer.peek(offset)
          
          if options[:skip_whitespace]
            while tag && tag.type == Token::Type::WHITESPACE
              offset += 1
              tag = @tokenizer.peek(offset)
            end
          end
          
          if type.nil?
            match = true if tag.nil?
          elsif ! tag.nil?
            match = true if tag.type == type
          end
        end
        
      else
        tag = @tokenizer.peek(offset)

        # Skip over whitespace
        if options[:skip_whitespace]
          while tag && tag.type == Token::Type::WHITESPACE
            offset += 1
            tag = @tokenizer.peek(offset)
          end
        end
        
        if tag
          match = true if tag.type == tag_set
        end
      end
      
      return false if match == false
      offset += 1
    end
  end

  def starts_line
    look_back(nil, Token::Type::WHITESPACE, Token::Type::NEWLINE)
  end

  def whole_line
    starts_line &&
      look_ahead([nil, Token::Type::NEWLINE])
  end

  def eat (tag)
    next_tag = @tokenizer.peek
    if next_tag && next_tag.type == tag
      @tokenizer.next_token
    end
  end
end
