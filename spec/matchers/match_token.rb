class MatchToken
  attr_accessor :type, :content, :token

  def initialize (expected)
    if expected.kind_of? Array
      (type, content) = expected
      self.type = type
      self.content = content
    else
      self.type = expected
      self.content = nil
    end
  end

  def matches? (token)
    self.token = token

    token.kind_of?(Token) &&
      token.type == type &&
      token.content == content
  end

  def failure_message
    "expected token (#{type}, #{content}) to match #{token.inspect}"
  end

  def failure_message
    "expected token (#{type}, #{content}) to not match #{token.inspect}"
  end
end