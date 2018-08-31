require 'anemone'
require 'kconv'

module Syumeigiku
  # anemoneを使ってurlからデータをとってくる
  class Crawler
    def initialize(config, parser)
      @url = config['url']
      @regexp = config['regexp']
      @anemone_opts = make_opts(config['anemone_opts'] || {})
      @parser = parser
      @data = {}
    end

    def self.crawl(config, parser)
      crawler = new(config, parser)
      crawler.run
    end

    def run
      Anemone.crawl(@url, @anemone_opts) do |anemone|
        anemone.focus_crawl { |page| pattern_links(page.links, @regexp) }
        anemone.on_every_page do |page|
          puts page.url
          merge_data(@parser.parse(page.body.toutf8))
        end
      end
      @data
    end

    private

    def make_opts(config_opts)
      default_opts = {
        delay: 1,
        storage: Anemone::Storage::SQLite3()
      }
      default_opts.merge(config_opts)
    end

    def merge_data(data2)
      @data.merge!(data2) { |_, val1, val2| val1 + val2 }
    end

    def pattern_links(links, regexp)
      return links unless regexp
      links.keep_if { |link| link.to_s.match(/#{regexp}/) }
      links
    end
  end
end
