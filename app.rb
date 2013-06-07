#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative 'util.rb'

class KakidameApp < Sinatra::Base
  include KakidameUtil

  CONFIG_PATH = ENV['HOME'] + '/.kakidame'

  configure do
    load CONFIG_PATH if File.exists?(CONFIG_PATH)
    KAKIDAME_ROOT = ENV['HOME'] + '/memo' unless defined? KAKIDAME_ROOT
    KAKIDAME_ROOT = File.absolute_path(KAKIDAME_ROOT) # ~ 対策

    unless Dir.exists?(KAKIDAME_ROOT)
      $stderr.puts "error: KAKIDAME_ROOT #{KAKIDAME_ROOT} is not found."
      exit 1
    end

    MARKDOWN_EXTENSION = ['md', 'markdown']
    FILE_EXTENSION = MARKDOWN_EXTENSION unless defined? FILE_EXTENSION

    unless FILE_EXTENSION.instance_of? Array
      $stderr.puts "error: FILE_EXTENSION must be Array."
      exit 1
    end
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
    @info = nil
    @relative_dir = dir_path.gsub(/^#{KAKIDAME_ROOT}/, "") + "/"
    @is_child, @files, @dirs = get_file_list(dir_path, KAKIDAME_ROOT, FILE_EXTENSION)

    erb :dir
  end

  def show_file(file_path)
    @info = get_file_info(file_path)
    @relative_dir = @info[:dir].gsub(/^#{KAKIDAME_ROOT}/, "") + "/"
    @is_child, @files, @dirs = get_file_list(@info[:dir], KAKIDAME_ROOT, FILE_EXTENSION)
    @html, @raw = parse_text_file(file_path)

    erb :file
  end
end
