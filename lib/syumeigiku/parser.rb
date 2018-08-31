require 'nokogiri'

module Syumeigiku
  # Crawlerのテストはしないがこっちはしてもいいかもしれない
  # pageのHTMLを設定に従いハッシュにして返す
  class Parser
    def initialize(items)
      @items = items
    end

    def parse(page)
      doc = Nokogiri::HTML.parse(page)
      @items.reduce({}) do |data, item|
        data[item['name']] =
          # リファクタリング
          extract_contents(doc, item)
        data
      end
    end

    private

    def extract_contents(doc, item)
      nodes = doc.css(item['selector'])
      unless nodes.empty?
        contents = extract_attribute(nodes, item['attribute']).map do |attr|
          replace_pattern(item, attr)
        end
      end
      return contents || []
    end

    def replace_pattern(item, attr)
      pattern = item['pattern']
      replacement = item['replacement']
      return attr.gsub(/#{pattern}/, replacement) if pattern && replacement
      raise 'patternとreplacementはセットで設定してください' if pattern || replacement
      attr
    end

    def extract_attribute(nodes, attribute)
      return nodes.map { |node| node.text.strip } if attribute == 'content'
      nodes.map { |node| node.attribute(attribute).text }
    end
  end
end