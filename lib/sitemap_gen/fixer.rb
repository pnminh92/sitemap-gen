module SitemapGen
  class Fixer
    def initialize(dir_path)
      @dir_path = dir_path
      @html_files = Dir.glob("#{dir_path}/**/*.html").select { |f| !f.include?('index.html') && !f.match(::SitemapGen::IGNORE_DIRS_REGEX) }
    end

    def execute
      @html_files.each do |f|
        p f
        new_path = "#{File.dirname(f)}/#{File.basename(f, '.*')}"
        new_html_file = "#{new_path}/index.html"
        FileUtils.mkdir_p(new_path)
        FileUtils.rm_rf(new_html_file)
        FileUtils.mv(f, new_html_file)
      end
    end
  end
end
