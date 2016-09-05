require "content_cleaner/version"
require 'nokogiri'

module ContentCleaner
  class Content
    def initialize(content)
      @doc = Nokogiri::HTML.parse(content)
      clean_content
    end

    def content_html
      @doc.xpath('//body').inner_html
    end

    protected
    def clean_content
      clean_paragraphs
    end

    def clean_paragraphs
      @doc.xpath('//p').each do |p|
        if p.inner_html == "\u00A0" then p.remove end

        last_node = p
        if p.text.to_s.strip.length == 0
          if p.inner_html == ''
            p.remove
            next
          end
          if p > 'script'
            # we have a script tag - move out of the p tag
            p.swap(p.inner_html)
            next
          end
        end

        if p.inner_html.include? '<figure'
          figures = p > 'figure'
          content_parts = p.inner_html.split(%r{<figure\b[^>]*>.*?</figure>})
          content_parts.each_with_index do |cp, index|
            if index == 0
              p.inner_html = cp
            else
              last_node = last_node.after("<p>#{cp}</p>")
            end
            unless figures[index].nil?
              last_node = last_node.after(figures[index].to_html)
            end
          end
        end

        if %r{(<br */?>\s*){2,}}.match(p.inner_html)
          content_parts = p.inner_html.split(%r{(<br */?>\s*){2,}})
          content_parts.each_with_index do |cp, index|
            if %r{(<br */?>\s*)}.match(cp)
              next
            end
            if index == 0
              p.inner_html = cp
            else
              last_node = last_node.after("<p>#{cp}</p>")
            end
          end
        end
      end
    end
  end
end
