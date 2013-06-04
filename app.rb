#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class KakidameApp < Sinatra::Base
  CONFIG_PATH = ENV['HOME'] + '/.kakidame'

  configure do
    load CONFIG_PATH if File.exists?(CONFIG_PATH)
    KAKIDAME_ROOT = ENV['HOME'] + '/memo' unless defined? KAKIDAME_ROOT
    Dir.mkdir(KAKIDAME_ROOT) unless Dir.exists?(KAKIDAME_ROOT)
  end

  configure :development do
    Bundler.require :development
    register Sinatra::Reloader
  end

  # Root
  get '/' do
    show_dir(KAKIDAME_ROOT)
  end

  # Directory
  get '/*/' do
    dir_name = params[:splat].join('/') + '/'
    dir_path = File.absolute_path(dir_name, KAKIDAME_ROOT)

    unless Dir.exists?(dir_path)
      return "404 not found"
    end

    show_dir(dir_path)
  end

  # File
  get '/*' do
    relative_path = params[:splat].join('/')
    file_path = File.absolute_path(relative_path, KAKIDAME_ROOT)

    if Dir.exists?(file_path)
      redirect relative_path + '/'
    elsif !File.exists?(file_path)
      return "404 not found"
    else
      show_file(file_path)
    end
  end

  private
  def show_dir(dir_path)
    @is_child, @files, @dirs = get_file_list(dir_path)

    erb :dir
  end

  def show_file(file_path)
    @is_child, @files, @dirs = get_file_list(File.dirname(file_path))

    markdown = File.open(file_path).read
    @html = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(markdown)
    @current_file = File.basename(file_path)

    erb :file
  end

  def get_file_list(dir_path)
    is_child = dir_path != KAKIDAME_ROOT

    files = []
    dirs = []
    Dir.chdir(dir_path)

    Dir.glob('*') do |f|
      if File::ftype(f) == "file"
        if f =~ /\.md$/i
          title = extract_markdown_title(f)
          files << [title, f]
        end
      else
        dirs << f + '/'
      end
    end

    return is_child, files, dirs
  end

  def extract_markdown_title(file_path)
    markdown = File.open(file_path).read

    title =
      if markdown.split("\n")[0] =~ /^#(.+)$/
        $1.strip
      else
        file_path
      end
  end
end
