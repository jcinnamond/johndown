class Content < Array
  def << (element)
    if element == "\n" && last.kind_of?(String)
      super

    elsif element == "\n"
      # ignore it

    elsif last == "\n" && element.kind_of?(String)
      super

    elsif last == "\n"
      pop
      super

    elsif last.kind_of?(String) && element.kind_of?(String)
      str = self.pop
      str += element
      super(str)

    else
      super
    end
  end

  def trim
    pop if last == "\n"
    self
  end
end
