require 'nokogiri'
require 'csv'
require 'benchmark'
require 'sitemap_gen/csv'

module SitemapGen
  def self.run(dir_path, base_url, save_path = nil)
    SitemapGen::Csv.new(dir_path, base_url, save_path).generate
  end
  #class << self
    #def run(dir_path, base_url, save_path = nil)
      #p Benchmark.measure { generate_csv(csv_data(dir_path, base_url), save_path) }
    #end

    #def generate_csv(data, save_path)
      #lheaders = level_headers(data)
      #save_path ||= Dir.pwd
      #CSV.open("#{save_path}/sitemap.csv", 'wb') do |csv|
        #csv << ['id'].concat(lheaders).push('url')
        #data.each_with_index do |row, i|
          #gap = lheaders.length - row[:levels].values.length
          #csv << [i + 1].concat(row[:levels].values).concat(Array.new(gap) { '' }).push(row[:url])
        #end
      #end
    #end

    #def level_headers(data)
      #data.each_with_object([]) { |item, o| o << item[:levels] }
          #.inject([]) { |max, row| max.size < row.keys.size ? row.keys : max }
    #end

    #def csv_data(dir_path, base_url)
      ## Raise error if there is no html files
      #html_files = Dir.glob("#{dir_path}/**/index.html")
      #raise 'There is no html files in your directory' if html_files.empty?

      #data = []
      #html_files.each_with_index do |file_path, i|
        #next if file_path =~ IGNORE_DIRS_REGEX
        #page_path = file_path.sub(dir_path, '')
        #base_path = File.dirname(page_path)
        #last_slash = base_path == '/' ? '' : '/'
        #short_page_path = page_path.split('/')[0..-2].join('/')
        #data.push({ url: base_url + base_path + last_slash, page_path: short_page_path == '' ? '/' : short_page_path  }
                  #.merge({ levels: dir_levels(dir_path, page_path) }))
      #end
      #organized_data(dir_path, data)
    #end

    #def page_title(file_path)
      #html_doc = Nokogiri::HTML(File.read(file_path))
      #html_doc.css('head title').first.content
    #end

    #def dir_levels(dir_path, page_path)
      #levels = {}
      #order = 0
      #page_path.split('/')[1..-2].each_with_index do |dir, i|
        #order = i + 1
        #levels.merge!({"level_#{order}": ''})
      #end
      #html_file = Dir.glob("#{dir_path}#{page_path}").first
      #levels.merge!({"level_#{order + 1}": page_title(html_file)})
      #levels
    #end

    #def organized_data(dir_path, data)
      #top_level_dirs = Dir.glob("#{dir_path}/**/index.html").map { |path| File.dirname(path).sub(dir_path, '').split('/')[0..-1].join('/') }.uniq
      #organized_data = []
      #organized_data.concat data.select { |d| d[:page_path] == '/' }
      #top_level_dirs.each do |dir|
        ## We group data by page path and then order by alphabet
        #organized_data.concat(data.select { |d| d[:page_path] =~ /\A#{Regexp.quote(dir)}\z/ }.sort_by { |d| d[:page_path] })
      #end
      #organized_data
    #end
  #end
end
