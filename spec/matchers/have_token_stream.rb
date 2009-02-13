class HaveTokenStream
  attr_accessor :tokens, :tokenizer

  def initialize (expected)
    self.tokens = expected
  end

  def matches? (tokenizer)
    self.tokenizer = tokenizer

    tokens.each do |next_token|
      t = tokenizer.next_token
      return false unless MatchToken.new(next_token).matches?(t)
    end

    return false unless tokenizer.next_token.nil?

    true
  end

  def failure_message
    "expected #{tokens.inspect} to match #{tokenizer.tokens.inspect}"
  end

  def negative_failure_message
    "expected #{tokens.inspect} to not match #{tokenizer.tokens.inspect}"
  end
end