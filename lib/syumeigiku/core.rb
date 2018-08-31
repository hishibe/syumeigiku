require 'yaml'
require_relative 'crawler'
require_relative 'parser'

# YAMLでクローラーを作れるライブラリ
# TODO: ハッシュのアクセス方法をシンボルに統一したい
module Syumeigiku
  # クローリングを始めるためのメソッド
  # @return [Hash] クローリング結果のハッシュ
  def self.crawl(options = {})
    Core.crawl(options)
  end

  # 外部から一番最初に呼び出されるクラス
  # YAMLのパースなども行う
  class Core
    # @param [Hash] options initializeに渡す引数optionsの中の説明は{#initialize}に書いてある
    def self.crawl(options)
      core = new(options)
      core.run
    end

    # @param [String] config_path YAMLのパス
    # @param [Hash] config 設定のハッシュ
    def initialize(config_path: nil, config: nil)
      apply_config_file(config_path) if config_path
      apply_config(config) if config
    end

    def run
      parser = Parser.new(@config['items'])
      Crawler.crawl(@config, parser)
    end

    private

    def apply_config_file(config_path)
      config = YAML.load_file config_path
      apply_config config
    end

    def apply_config(config)
      @config = config
    end
  end
end
