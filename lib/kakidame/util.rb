#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'nkf'
require 'redcarpet'
require 'dalli'

module Kakidame
  module Util
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

    def get_file_list(dir_path, root_dir, extension, cache)
      is_child = dir_path != root_dir

      if (files = cache.get("files:#{dir_path}")) && (dirs = cache.get("dirs:#{dir_path}"))
        return is_child, files, dirs
      end

      files = []
      dirs = []

      Dir.chdir(dir_path)

      Dir.glob('*') do |f|
        if File::ftype(f) == "directory"
          dirs << f + '/'
        else
          file_ext = get_file_ext(f)

          if extension.include?(file_ext)
            title = if MARKDOWN_EXTENSION.include?(file_ext)
                      extract_markdown_title(f)
                    else
                      ""
                    end
            files << {title: title, file_name: f}
          end
        end
      end

      files = files.sort_by { |file| file[:title] }
      dirs = dirs.sort

      cache.set("files:#{dir_path}", files)
      cache.set("dirs:#{dir_path}", dirs)

      return is_child, files, dirs
    end

    def parse_text_file(file_path)
      text = NKF.nkf('-w', File.open(file_path).read)
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

    def search(dir_path, search_query, extension)
      results = []
      is_child, files, dirs = get_file_list(dir_path, dir_path, extension)

      files.each do |file|
        f_path = File.absolute_path(file[:file_name], dir_path)
        results << f_path if search_file(f_path, search_query)
      end

      dirs.each do |dir|
        d_path = File.absolute_path(dir, dir_path)
        results.concat search(d_path, search_query, extension)
      end

      results
    end

    private
    def extract_markdown_title(file_path)
      markdown = NKF.nkf('-w', File.open(file_path).read)

      title =
        if markdown.split("\n")[0] =~ /^#+(.+)$/
          $1.strip
        else
          ""
        end
    end

    def get_file_ext(file_name)
      File.extname(file_name).gsub('.', '')
    end

    def search_file(file_path, search_query)
      text = NKF.nkf('-w', File.open(file_path).read)
      text.each_line { |line| return true if line =~ /#{search_query}/i }
      false
    end
  end
end
