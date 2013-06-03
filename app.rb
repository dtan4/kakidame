#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class KakidameApp < Sinatra::Base
  CONFIG_PATH = ENV['HOME'] + '/.kakidame'

  configure do
    load CONFIG_PATH if File.exists?(CONFIG_PATH)
    KAKIDAME_ROOT = ENV['HOME'] + '/memo' unless defined? KAKIDAME_ROOT
  end

  configure :development do
    Bundler.require :development
    register Sinatra::Reloader
  end

  # Root
  get '/' do
    "Root: " + KAKIDAME_ROOT
  end

  # Directory
  get '/*/' do
    dir_path = File.absolute_path(params[:splat].join('/') + '/', KAKIDAME_ROOT)

    unless Dir.exists?(dir_path)
      "404 not found"
    else
      dir_path
    end
  end

  # File
  get '/*' do
    file_path = File.absolute_path(params[:splat].join('/'), KAKIDAME_ROOT)

    unless File.exists?(file_path)
      "404 not found"
    else
      markdown = File.open(file_path).read
      Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(markdown)
    end
  end
end
