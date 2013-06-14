#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module KakidameUtil
  MARKDOWN_EXTENSION = ['md', 'markdown']
  SOURCE_CODE_EXTENSION = [
                           'c',
                           'cpp',
                           'h',
                           'java',
                           'rb',
                           'py',
                           'pl',
                           'js',
                           'html'
                          ]

  def get_file_list(dir_path, root_dir, extension)
    is_child = dir_path != root_dir

    files = []
    dirs = []
    Dir.chdir(dir_path)

    Dir.glob('*') do |f|
      if File::ftype(f) == "file"
        file_ext = get_file_ext(f)

        if extension.include?(file_ext)
          title = if MARKDOWN_EXTENSION.include?(file_ext)
                    extract_markdown_title(f)
                  else
                    f
                  end
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
    extension = get_file_ext(file_path)
    html = nil

    if MARKDOWN_EXTENSION.include?(extension)
      html = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text)
    elsif SOURCE_CODE_EXTENSION.include?(extension)
      html = "<pre class=\"prettyprint linenums\">\n" + CGI.escapeHTML(text) + "\n</pre>"
    end

    raw = CGI.escapeHTML(text)

    return html, raw
  end

  def get_file_info(file_path)
    info = {
      fullpath: file_path,
      dir: File.dirname(file_path),
      name: File.basename(file_path),
      modified_at: File.mtime(file_path)
    }
  end

  private
  def extract_markdown_title(file_path)
    markdown = File.open(file_path).read

    title =
      if markdown.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8").split("\n")[0] =~ /^#+(.+)$/
        $1.strip
      else
        file_path
      end
  end

  def get_file_ext(file_name)
    File.extname(file_name).gsub('.', '')
  end
end
