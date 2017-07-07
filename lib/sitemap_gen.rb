require 'nokogiri'
require 'csv'
require 'sitemap_gen/csv'

module SitemapGen
  def self.run(dir_path, base_url, save_path = nil)
    SitemapGen::Csv.new(dir_path, base_url, save_path).generate
  end
end
