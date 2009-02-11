unless ActionView::Base.instance_methods.include? 'johndown'
  require 'johndown'
  
  ActionView::Base.class_eval do
    def johndown (s)
      Johndown.new(s).to_s
    end
  end
end
