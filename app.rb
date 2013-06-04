#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'util.rb'

class KakidameApp < Sinatra::Base
  include KakidameUtil

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
    else
      if !File.exists?(file_path)
        return "404 not found"
      else
        show_file(file_path)
      end
    end
  end

  private
  def show_dir(dir_path)
    @is_child, @files, @dirs = get_file_list(dir_path)

    erb :dir
  end

  def show_file(file_path)
    @is_child, @files, @dirs = get_file_list(File.dirname(file_path))
    @html = generate_html_from_markdown(file_path)
    @current_file = File.basename(file_path)
    @modified_at = File.mtime(file_path)

    erb :file
  end
end
