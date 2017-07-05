require 'nokogiri'
require 'csv'

module SitemapGen
  IGNORE_DIRS_REGEX = /img|cgi-bin|images|css|js/i

  class << self
    def run(dir_path, base_url, save_path = nil)
      generate_csv(csv_data(dir_path, base_url), save_path)
    end

    def generate_csv(data, save_path)
      level_header = data.each_with_object([]) { |item, o| o << item[:levels] }
                         .inject([]) { |max, row| max.size < row.keys.size ? row.keys : max }
      save_path ||= Dir.pwd
      CSV.open("#{save_path}/sitemap.csv", 'wb') do |csv|
        csv << ['id'].concat(level_header).push('url')
        data.each_with_index do |row, i|
          gap = level_header.length - row[:levels].values.length
          csv << [i + 1].concat(row[:levels].values).concat(Array.new(gap) { '' }).push(row[:url])
        end
      end
    end

    def csv_data(dir_path, base_url)
      # If there is a foward slash at the end of dir path then remove it
      #dir_path = dir_path[0..-2] if dir_path[-1] =~ /\//

      # Exit if there is no html files
      html_files = Dir.glob("#{dir_path}/**/*.html")
      exit if html_files.empty?

      data = []
      html_files.each_with_index do |file_path, i|
        next if file_path =~ IGNORE_DIRS_REGEX
        server_pathname = file_path.sub(dir_path, '')
        base_path = File.dirname(server_pathname)
        last_slash = base_path == '/' ? '' : '/'
        data.push({ url: base_url + base_path + last_slash}
                  .merge({ levels: dir_levels(dir_path, server_pathname) }))
      end
      data
    end

    def page_title(file_path)
      html_doc = Nokogiri::HTML(File.read(file_path))
      html_doc.css('head title').first.content
    end

    def dir_levels(dir_path, server_pathname)
      levels = {}
      dirs = server_pathname.split('/')

      # Drop first and last element of dirs array, because they are a empty string and a filename
      dirs[1..-2].each_with_index do |dir, i|
        current_dir_index = dirs.index(dir)
        current_path = dirs[0..current_dir_index].join('/')
        html_file = Dir.glob("#{dir_path}#{current_path}/index.html").first
        levels.merge!({"level_#{i + 1}": page_title(html_file)})
      end
      levels
    end
  end
end
