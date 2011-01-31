def load_gems(gems, path)
  gems.each { |gem| Dir.glob(File.join(path, gem + "*")).each {
    |item| puts item; $LOAD_PATH.unshift File.expand_path(File.join(item, "lib")) }
}
end

# ideally we want to load .gems/bundler_gems/jruby/1.0/environment.rb
# this is needed because of issues with the rake test output not showing when .gems/bundler_gems/jruby/1.0/environment.rb is loaded
load_gems(["extlib",
 "addressable", "dm-core", "dm-validations",
 "dm-appengine", "lexidecimal", "appengine-apis",
 "rack", "sinatra", "tilt", "httparty", "crack", "mogli", "hashie", "oauth", "jruby-openssl", "json"
], File.join(File.dirname(File.expand_path(__FILE__)), ".gems/bundler_gems/jruby/1.8/gems"))

# Appengine bundler does not support installing gems for testing only.
# Hence, we install these gems in an external Jruby env and use them for tests.
# The following gems for testing expected to be installed and to be loaded from JRuby gem path
# rvm install jruby
# gem install cucumber
# gem install capybara (requires Nokogiri which has issues with app-engine jruby)
# gem install selenium-client

load_gems(["rspec", "diff-lcs", "rack-test", "gherkin-2.3.3-java", "cucumber", "selenium-client"],
 File.join(ENV['JRUBY_HOME'], "lib", "ruby", "gems", "jruby", "gems")
)




