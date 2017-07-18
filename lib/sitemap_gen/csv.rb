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
        p 'Generating and checking page url...'
        @html_files.each do |f|
          next if f =~ ::SitemapGen::IGNORE_DIRS_REGEX
          page_url = @base_url + server_path(f)
          p page_url
          sitemaps.push({ url: page_url, levels: dir_levels(f), status: page_status(page_url) })
        end
        p 'Finish generating url'
        sitemaps
      end

      def csv_header
        header = ['Id']
        @max_level.to_i.times.each { |l| header.push("Level #{l + 1}") }
        header.push('Url').push('Status')
      end

      def csv_row(item, order_num)
        titles = item[:levels].values
        gap = @max_level - titles.size
        [order_num + 1].concat(titles)
                       .concat(Array.new(gap) { '' })
                       .push(item[:url], item[:status])
      end

      def page_status(page_url)
        begin
          page_uri = URI(page_url)
          res = Net::HTTP.get_response(page_uri)
          ['200', '301', '302'].include?(res.code) ? 'Passed' : 'Failed'
        rescue URI::InvalidURIError
          'Wrong format URL'
        end
      end

      def html_page_title(file_path)
        html_doc = Nokogiri::HTML(File.read(file_path))
        html_doc.css('head title')&.first&.content
      end

      def dir_levels(file_path)
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
