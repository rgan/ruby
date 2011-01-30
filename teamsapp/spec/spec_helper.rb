require 'rspec'
require 'dm-core'
require 'dm-validations'

require 'appengine-apis/testing'
AppEngine::Testing.boot
require "appengine_adapter"
DataMapper.setup(:default, "appengine://auto")