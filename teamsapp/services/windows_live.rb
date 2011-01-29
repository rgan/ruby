require 'httparty'
require 'appengine-apis/logger'
require 'json'

class WindowsLive
  include HTTParty
  include ServiceUtils

  def initialize()
    @logger = AppEngine::Logger.new(nil)
  end

  def authorize_url(client_id, app_url)
      "https://consent.live.com/Connect.aspx?wrap_client_id=#{client_id}&wrap_callback=#{app_url}&wrap_scope=WL_Contacts.View"
  end

  def access_token(env_info, verification_code)
    begin
      response = self.class.post("https://consent.live.com/AccessToken.aspx",
                      :body => { "wrap_client_id" => env_info[:windows_live_client_id],
                                 "wrap_client_secret" => env_info[:windows_live_client_secret],
                                 "wrap_callback" => env_info[:url],
                                 "wrap_verification_code" => verification_code,
                                 "idtype" => "CID"})
      token_from_response(response)
    rescue Exception => e
      @logger.info(e.message)
    end
  end

  def contacts(client_id, access_token)
    begin
      response = self.class.get("https://bay.apis.live.net/V4.1/cid-#{client_id}/Contacts/AllContacts",
                                { :headers => {"Accept" => "application/json", "Authorization" => "#{access_token.access_token}"}})
      @logger.info(response.body)
      to_contacts(response.body)
    rescue Exception => e
      @logger.info(e.message)
      []
    end

  end

  def token_from_response(response)
    WindowsToken.new(response_to_hash(response))
  end

  def to_contacts(contacts_json)
    members = []
    contacts = JSON(contacts_json)
    contacts["Entries"].each do |entry|
      members << TeamMember.new(:name => entry["FormattedName"], :windows_id => entry["Id"])
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