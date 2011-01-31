Given /^I visit the home page$/ do
  @browser.open "/"
end

Then /^I should see '(.*)'$/ do |text|
  @browser.text?(text).should be_true
end