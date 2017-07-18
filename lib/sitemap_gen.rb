require 'nokogiri'
require 'fileutils'
require 'csv'
require 'net/http'
require 'byebug'

module SitemapGen
  IGNORE_DIRS_REGEX = /img|cgi-bin|images|css|js/i

  autoload :CSV, 'sitemap_gen/csv'
  autoload :Fixer, 'sitemap_gen/fixer'

  def self.generate(dir_path, base_url, save_path = nil)
    CSV.new(dir_path, base_url, save_path).execute
  end

  def self.fix(dir_path)
    Fixer.new(dir_path).execute
  end
end
