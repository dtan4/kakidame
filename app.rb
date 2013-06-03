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
    file_path = File.absolute_path(params[:splat].join('/'), KAKIDAME_ROOT)

    if Dir.exists?(file_path)
      return show_dir(file_path)
    elsif !File.exists?(file_path)
      return "404 not found"
    end

    show_file(file_path)
  end

  private
  def show_dir(dir_path)
    @files = []
    @dirs = []
    Dir.chdir(dir_path)

    Dir.glob('*') do |f|
      if File::ftype(f) == "file"
        @files << f if f =~ /\.md$/i
      else
        @dirs << f + '/'
      end
    end

    @files = @files.map { |f| "<a href=\"#{f}\">#{f}</a>" }
    @dirs = @dirs.map { |d| "<a href=\"#{d}\">#{d}</a>" }

    @files.join("<br />") + "<hr />" + @dirs.join("<br />")
  end

  def show_file(file_path)
    markdown = File.open(file_path).read
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(markdown)
  end
end
