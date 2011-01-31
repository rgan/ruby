Before('@run_in_browser') do
  @browser = Selenium::Client::Driver.new \
            :host => "localhost",
            :port => 4444,
            :browser => "*firefox",
            :url => "http://localhost:8080",
            :timeout_in_second => 60
  @browser.start_new_browser_session
end

After('@run_in_browser') do
  @browser.close_current_browser_session
end