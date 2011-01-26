require 'oauth'
require 'appengine-apis/logger'
require 'json'

class Google

  def initialize()
    @logger = AppEngine::Logger.new(nil)
  end
  
  def request_token(app_url)
    begin
      @consumer = OAuth::Consumer.new("anonymous", "anonymous", {
        :site               => "https://www.google.com",
        :scheme             => :header,
        :http_method        => :post,
        :signature_method   => 'HMAC-SHA1',
        :request_token_path => "/accounts/OAuthGetRequestToken",
        :access_token_path  => "/accounts/OAuthGetAccessToken",
        :authorize_path     => "/accounts/OAuthAuthorizeToken",
      })
      @consumer.get_request_token({:oauth_callback => "#{app_url}"}, :scope => "https://www-opensocial.googleusercontent.com/api/people")
    rescue Exception => e
      @logger.info(e.message)
    end
  end

  def contacts(request_token, verifier)
    begin
      @access_token = request_token.get_access_token({:oauth_verifier => verifier})
      response = @access_token.get("https://www-opensocial.googleusercontent.com/api/people/@me/@all")
      case response.code.to_i
        when (200..299)
          return to_members(response.body)
        else
          @logger.info(response.body)
      end
    rescue Exception => e
      @logger.info(e.message)
    end
    []
  end

  def to_members(contacts_json)
    members = []
    begin
      contacts = JSON(contacts_json)
      contacts["entry"].each do |entry|
        members << TeamMember.new(:name => entry["displayName"], :google_id => entry["id"])
      end
    rescue
    end

    members
  end
  
end