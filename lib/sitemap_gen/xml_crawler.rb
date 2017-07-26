module Enumerable
  def with_multithread(thread_num)
    queue = Queue.new
    threads = (1..thread_num).map do
      Thread.new do
        until queue.empty?
          begin
            yield(queue.pop)
          rescue Exception
            nil
          end
        end
      end
    end

    each { |v| queue << v }
    threads.each { |t| t.join }
  end
end

module SitemapGen
  class XMLCrawler
    def self.execute(xml_path, save_path)
      save_path ||= Dir.pwd
      xml = File.open(xml_path) { |f| Nokogiri::XML(f) }
      links = xml.css('loc').map(&:content)
      ::CSV.open("#{save_path}/sitemap_only_link_title.csv", 'wb') do |csv|
        csv << ['ID', 'Page title', 'URL']
        links.with_multithread(8) do |link|
          p link
          res = Net::HTTP.get_response(URI(link))
          html = Nokogiri::HTML(res.body)
          title = html.css('head title')&.first&.content
          csv << ['', title, link]
        end
      end
    end
  end
end
