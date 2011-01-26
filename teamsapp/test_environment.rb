file = File.expand_path(__FILE__)
dir = File.join(File.dirname(file), ".gems/bundler_gems/jruby/1.8/gems")

["rspec", "diff-lcs", "extlib",
 "addressable", "dm-core", "dm-validations",
  "dm-appengine", "lexidecimal", "appengine-apis",
  "sinatra", "tilt", "httparty", "crack", "mogli", "hashie", "oauth", "jruby-openssl"

].each { |gem| Dir.glob(File.join(dir, gem + "*")).each {
    |item| $LOAD_PATH.unshift File.expand_path(File.join(item, "lib"))}
}

