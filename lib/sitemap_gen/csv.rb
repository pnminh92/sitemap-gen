module SitemapGen
  class CSV
    def initialize(dir_path, base_url, save_path)
      @dir_path = dir_path
      @base_url = base_url
      @save_path = save_path || Dir.pwd
      @max_level = 1
      @html_files = Dir.glob("#{dir_path}/**/index.html").sort_by { |f| File.dirname(f) }
      raise 'There is no index.html files in your directory' if @html_files.empty?
      @sitemaps = create_sitemaps
    end

    def execute
      ::CSV.open("#{@save_path}/sitemap.csv", 'wb') do |csv|
        csv << csv_header
        @sitemaps.each_with_index { |item, i| csv << csv_row(item, i) }
      end
    end

    private

      def create_sitemaps
        sitemaps = []
        @html_files.each do |f|
          next if f =~ ::SitemapGen::IGNORE_DIRS_REGEX
          sitemaps.push({ url: @base_url + server_path(f), levels: dir_levels(f) })
        end
        sitemaps
      end

      def csv_header
        header = ['Id']
        @max_level.to_i.times.each { |l| header.push("Level #{l + 1}") }
        header.push('Url')
      end

      def csv_row(item, order_num)
        gap = @max_level - item[:levels].values.size
        [order_num + 1].concat(item[:levels].values).concat(Array.new(gap) { '' }).push(item[:url])
      end

      def html_page_title(file_path)
        html_doc = Nokogiri::HTML(File.read(file_path))
        html_doc.css('head title')&.first&.content
      end

      def dir_levels(file_path)
        p file_path
        levels = {}
        order = 0
        dirs = server_path(file_path).split('/')
        if dirs.empty?
          levels.merge!({"level_#{order += 1}": html_page_title(file_path)})
        else
          dirs[1..-1].each_with_index do |dir, i|
            levels.merge!({"level_#{order += 1}": ''})
          end
          levels.merge!({"level_#{order += 1}": html_page_title(file_path)})
        end
        set_max_level(order)
        levels
      end

      def server_path(file_path)
        File.dirname(file_path.sub(@dir_path, ''))
      end

      def set_max_level(num)
        @max_level = num > @max_level ? num : @max_level
      end
  end
end
