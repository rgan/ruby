require 'httparty'
require 'mogli'
require 'services/service_utils'
require 'appengine-apis/logger'

class Facebook

  include HTTParty
  include ServiceUtils

  def initialize(access_token=nil)
    @access_token = access_token
    @logger = AppEngine::Logger.new(nil)
  end

  def authorize_url(env_info_hash)
    authenticator(env_info_hash).authorize_url(:scope => 'publish_stream,read_stream', :display => 'page')
  end

  def create_access_token_from_code(code, env_info_hash)
    begin
      response = self.class.get(authenticator(env_info_hash).access_token_url(code))
      @logger.info(response)
      @access_token = response_to_hash(response)["access_token"]
    rescue Exception => e
      log(e.message)
      @access_token = nil
    end
  end

  def me()
    if @access_token
      begin
        response = self.class.get(path("me"), :query=>default_params())
        #@logger.info(response.body)
        to_user(response.body)
      rescue Exception => e
        log(e.message)
        nil
      end  
    end
  end

  def posts()
    if @access_token
      begin
        response = self.class.get(path("me/feed"), :query=>default_params().merge({:limit => 10}))
        #@logger.info(response.body)
        to_posts(response.body)
      rescue Exception => e
        log(e.message)
        []
      end
    end
  end

  def friends()
    if @access_token
      begin
        response = self.class.get(path("me/friends"), :query=>default_params().merge({:limit => 10}))
        #@logger.info(response.body)
        to_friends(response.body)
      rescue Exception => e
        log(e.message)
        []
      end
    end
  end

  def post_update(msg)
    if @access_token
      begin
        log("Facebook: posting update")
        self.class.post(path("me/feed"),:body=>default_params().merge({:message => msg}))
      rescue Exception => e
        log(e.message)
      end
    end
  end

  def to_user(json_string)
    FacebookUser.new(JSON(json_string))
  end

  def to_posts(json_string)
    posts = []
    JSON(json_string)["data"].each do |post|
      posts << FacebookPost.new(post)
    end
    posts
  end

  def to_friends(json_string)
    friends = []
    JSON(json_string)["data"].each do |friend|
      friends << TeamMember.new(:name => friend["name"], :facebook_id => friend["id"])
    end
    friends
  end

  private

  def log(msg)
    @logger.info("Facebook:" + msg)
  end

  def authenticator(env_info_hash)
    Mogli::Authenticator.new(env_info_hash[:fb_app_id], env_info_hash[:fb_secret], "#{env_info_hash[:url]}/oauth/create")
  end

  def default_params()
    @access_token ? {:access_token=> @access_token} : {}
  end

  def path(path)
    "https://graph.facebook.com/#{path}"
  end

end

class FacebookUser
  attr_reader :fb_id, :first_name, :last_name

  def initialize(json_hash)
    @fb_id = json_hash["id"]
    @first_name = json_hash["first_name"]
    @last_name = json_hash["last_name"]
  end
end

class FacebookPost
  attr_reader :fb_id, :message, :updated_time

  def initialize(json_hash)
    @fb_id = json_hash["id"]
    @message = json_hash["message"]
    @updated_time = json_hash["updated_time"]
  end
end