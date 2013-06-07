#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module KakidameUtil
  def get_file_list(dir_path, root_dir, extension)
    is_child = dir_path != root_dir

    files = []
    dirs = []
    Dir.chdir(dir_path)

    Dir.glob('*') do |f|
      if File::ftype(f) == "file"
        if extension.include?(File.extname(f)[1..-1])
          title = extract_markdown_title(f)
          files << {title: title, file_name: f}
        end
      else
        dirs << f + '/'
      end
    end

    files = files.sort_by { |file| file[:title] }
    dirs = dirs.sort

    return is_child, files, dirs
  end

  def parse_text_file(file_path)
    text = File.open(file_path).read

    # TODO: if Markdown file
    html = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text)
    raw = CGI.escapeHTML(text)

    return html, raw
  end

  def extract_markdown_title(file_path)
    markdown = File.open(file_path).read

    title =
      if markdown.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8").split("\n")[0] =~ /^#+(.+)$/
        $1.strip
      else
        file_path
      end
  end

  def get_file_info(file_path)
    info = {
      fullpath: file_path,
      dir: File.dirname(file_path),
      name: File.basename(file_path),
      modified_at: File.mtime(file_path)
    }
  end
end
