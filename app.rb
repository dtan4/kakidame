#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sinatra/base'

CONFIG_PATH = ENV['HOME'] + '/.kakidame'

class KakidameApp < Sinatra::Base
  configure do
    load CONFIG_PATH if File.exists?(CONFIG_PATH)
    KAKIDAME_ROOT = ENV['HOME'] + '/memo' unless defined? KAKIDAME_ROOT
  end

  configure :development do
    Bundler.require :development
    register Sinatra::Reloader
  end

  get '/' do
    KAKIDAME_ROOT
  end
end
