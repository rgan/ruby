require 'httparty'
require 'appengine-apis/logger'
require 'json'

class WindowsLive
  include HTTParty
  include ServiceUtils

  def initialize(env_info=nil)
    @env_info = env_info
    @logger = AppEngine::Logger.new(nil)
  end

  def authorize_url()
      "https://consent.live.com/Connect.aspx?wrap_client_id=#{@env_info[:windows_live_client_id]}&wrap_callback=#{@env_info[:url]}&wrap_scope=WL_Contacts.View,WL_Profiles.View,WL_Activities.Update"
  end

  def access_token(verification_code)
    begin
      response = self.class.post("https://consent.live.com/AccessToken.aspx",
                      :body => { "wrap_client_id" => @env_info[:windows_live_client_id],
                                 "wrap_client_secret" => @env_info[:windows_live_client_secret],
                                 "wrap_callback" => @env_info[:url],
                                 "wrap_verification_code" => verification_code,
                                 "idtype" => "CID"})
      token_from_response(response)
    rescue Exception => e
      log(e.message)
    end
  end

  def contacts(access_token)
    begin
      response = self.class.get("#{path(@env_info[:windows_live_client_id])}/Contacts/AllContacts",
                                { :headers => default_headers(access_token.access_token)})
      log(response.body)
      to_contacts(response.body)
    rescue Exception => e
      log(e.message)
      nil
    end
  end

  def post_update(access_token, message)
    return if access_token.nil?
    begin
      log("Windows Live: post_update...")
      response = self.class.post("#{path(@env_info[:windows_live_client_id])}/MyActivities",
                                 { :body => post_message(message, @env_info[:url]),
                                   :headers => default_headers(access_token).merge({"Content-Type" =>  "application/json"})})
      log(response.body)
    rescue Exception => e
      log(e.message)
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

  private

  def log(msg)
    @logger.info("windows_live update:" + msg)
  end
  
  def post_message(message, url)
    '{"__type" : "CustomActivity:http://schemas.microsoft.com/ado/2007/08/dataservices",
      "CustomActivityVerb" : ' + '"' + message +
      '","ApplicationLink" : "' + url + '",
      "ActivityObjects" : [
        {
          "ActivityObjectType" : "http://activitystrea.ms/schema/1.0/custom",
          "Title" : "Test",
          "Summary" : "Team description",
          "AlternateLink" : "https://foobar",
          "PreviewLink" : "https://foobar"
        }
      ]
    }'
  end

  def path(client_id)
    "https://apis.live.net/V4.1/cid-#{client_id}"
  end

  def default_headers(access_token)
    {"Accept" => "application/json", "Authorization" => "WRAP access_token=#{access_token}"}
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