require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Content do
  before(:each) do
    @content = Content.new
  end

  it "should add elements like an array" do
    @content << "a string"
    @content << 1
    obj = Object.new
    @content << obj

    @content.should == ["a string", 1, obj]
  end

  it "should concatinate strings" do
    @content << "first"
    @content << " "
    @content << "second"
    @content.should == ["first second"]
  end

  it "should not concatinate strings if another type is added in the middle" do
    @content << "first"
    @content << " "
    @content << 1
    @content << "second"
    @content.should == ["first ", 1, "second"]
  end

  it "should not concatinate newlines" do
    @content << "first"
    @content << "\n"
    @content << "second"
    @content.should == ["first", "\n", "second"]
  end

  it "should remove newlines between strings and non-strings" do
    @content << "first"
    @content << "\n"
    @content << 1
    @content.should == ["first", 1]
  end

  it "should remove newlines between non-strings and strings" do
    @content << 1
    @content << "\n"
    @content << "first"
    @content.should == [1, "first"]
  end

  it "should trim trailing whitespaces" do
    @content << "first"
    @content << "\n"
    @content.trim.should == ["first"]
  end
end