require 'httparty'
require 'appengine-apis/logger'
require 'json'

class WindowsLive
  include HTTParty

  def initialize()
    @logger = AppEngine::Logger.new(nil)
  end

  def authorize_url(client_id, app_url)
      "https://consent.live.com/Connect.aspx?wrap_client_id=#{client_id}&wrap_callback=#{app_url}&wrap_scope=WL_Contacts.View"
  end

  def access_token(env_info, verification_code)
    response = self.class.post("https://consent.live.com/AccessToken.aspx",
                    :body => { "wrap_client_id" => env_info[:windows_live_client_id],
                               "wrap_client_secret" => env_info[:windows_live_client_secret],
                               "wrap_callback" => env_info[:url],
                               "wrap_verification_code" => verification_code,
                               "idtype" => "CID"})
    token = token_from_response(response)
  end

  def contacts(client_id, access_token)
    response = self.class.get("https://apis.live.net/V4.1/cid-#{client_id}/Contacts/AllContacts",
                              { :headers => {"Accept" => "application/json", "Authorization" => "#{access_token.access_token}"}})
    @logger.info(response.body)
    to_contacts(response.body)
  end

  def token_from_response(response)
    parts = response.split("&")
    hash = {}
    parts.each do |p| (k,v) = p.split("=")
        hash[k]=CGI.unescape(v)
    end
    WindowsToken.new(hash)
  end

  def to_contacts(contacts_json)
    members = []
    begin
      contacts = JSON(contacts_json)
      contacts["Entries"].each do |entry|
        members << TeamMember.new(:name => entry["FormattedName"], :windows_id => entry["Id"])
      end
    rescue
    end

    members
  end
end

class WindowsToken
  attr_reader :access_token, :refresh_token, :expires_in

  def initialize(attributes)
    @access_token = attributes["wrap_access_token"]
    @refresh_token = attributes["wrap_refresh_token"]
    @expires_in = attributes["wrap_access_token_expires_in"]
  end

end