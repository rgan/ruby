# this is needed because of issues with the rake test output not showing when .gems/bundler_gems/jruby/1.0/environment.rb is loaded
dir  = File.join(File.dirname(File.expand_path(__FILE__)), ".gems/bundler_gems/jruby/1.8/gems")
["rspec", "diff-lcs", "extlib",
 "addressable", "dm-core", "dm-validations",
 "dm-appengine", "lexidecimal", "appengine-apis",
 "sinatra", "tilt", "httparty", "crack", "mogli", "hashie", "oauth", "jruby-openssl"
].each { |gem| Dir.glob(File.join(dir, gem + "*")).each {
    |item| $LOAD_PATH.unshift File.expand_path(File.join(item, "lib")) }
}
