require 'nokogiri'
require 'fileutils'
require 'csv'
require 'net/http'

module SitemapGen
  IGNORE_DIRS_REGEX = /img|cgi-bin|images|css|js/i

  autoload :CSV, 'sitemap_gen/csv'
  autoload :Fixer, 'sitemap_gen/fixer'
  autoload :XMLCrawler, 'sitemap_gen/xml_crawler'

  def self.generate(dir_path, base_url, save_path = nil)
    CSV.new(dir_path, base_url, save_path).execute
  end

  def self.fix(dir_path)
    Fixer.new(dir_path).execute
  end

  def self.crawl_xml(xml_path, save_path)
    XMLCrawler.execute(xml_path, save_path)
  end
end
