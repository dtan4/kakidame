#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'sinatra/base'

class KakidameApp < Sinatra::Base
  get '/' do
    "Kakidame"
  end
end
