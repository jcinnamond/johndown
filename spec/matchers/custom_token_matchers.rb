require File.join(File.dirname(__FILE__), 'match_token')
require File.join(File.dirname(__FILE__), 'have_token_stream')

module CustomTokenMatchers
  def have_token_stream (*tokens)
    HaveTokenStream.new(tokens)
  end

  def match_token (expected)
    MatchToken.new(expected)
  end
end
