require 'spec_helper'
require 'content_cleaner'

describe ContentCleaner do

  def cleaned_content(html)
    cleaned_value(ContentCleaner::Content.new(html).content_html)
  end

  def cleaned_value(value)
    value.gsub(/\s+/,'')
  end

  it 'has a version number' do
    expect(ContentCleaner::VERSION).not_to be nil
  end

  it "should remove empty tags" do
    html1 = <<-HTML
      <p></p>
    HTML

    expected1 = <<-HTML

    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "should remove p tags with &nbsp;" do
    html1 = <<-HTML
      <p>&nbsp;</p>
    HTML

    expected1 = <<-HTML

    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "moves a figure right before the end of a paragraph out of the p tag" do
    html1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.<figure><img src="example.com/img.jpg"></figure></p>
    HTML
    expected1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p><figure><img src="example.com/img.jpg"></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "splits a paragraph with multiple figures into parts" do
    html1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. <figure><img src="example.com/img.jpg"></figure> Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.<figure><img src="example.com/img.jpg"></figure></p>
    HTML
    expected1 = <<-HTML
        <p>
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</p><figure><img src="example.com/img.jpg"></figure><p> Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p><figure><img src="example.com/img.jpg"></figure>
    HTML
    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end

  it "removes p tags around script tags" do
    html1 = <<-HTML
        <p></p>
        <p>
        <script src="//platform.twitter.com/widgets.js"></script>
        </p>
    HTML
    expected1 = <<-HTML
        <script src="//platform.twitter.com/widgets.js"></script>
    HTML

    expect(cleaned_content(html1)).to eq(cleaned_value(expected1))
  end
end
