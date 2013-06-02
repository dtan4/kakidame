#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sinatra/base'

class KakidameApp < Sinatra::Base
  configure :development do
    Bundler.require :development
    register Sinatra::Reloader
  end

  get '/' do
    "Kakidame"
  end
end
