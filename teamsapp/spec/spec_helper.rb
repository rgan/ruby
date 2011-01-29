require File.expand_path(File.join(File.dirname(__FILE__), "../test_environment"))
#require File.expand_path(File.join(File.dirname(__FILE__), "../.gems/bundler_gems/jruby/1.8/environment.rb"))

require 'rspec'
require 'dm-core'
require 'dm-validations'

require 'appengine-apis/testing'
AppEngine::Testing.boot
require "appengine_adapter"
DataMapper.setup(:default, "appengine://auto")