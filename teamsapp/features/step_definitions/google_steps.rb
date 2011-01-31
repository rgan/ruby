require 'services/google'

Before do
  @svc = Google.new
end

After do
end

Then /^return a non-nil oauth request token for (.*)$/ do |url|
  @svc.request_token(url).should_not be_nil
end