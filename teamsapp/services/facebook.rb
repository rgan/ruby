require 'httparty'
require 'mogli'
require 'appengine-apis/logger'

class Facebook

  include HTTParty

  def initialize(access_token=nil)
    @access_token = access_token
    @logger = AppEngine::Logger.new(nil)
  end

  def authorize_url(env_info_hash)
    authenticator(env_info_hash).authorize_url(:scope => 'publish_stream,read_stream', :display => 'page')
  end

  def create_access_token_from_code(code, env_info_hash)
    begin
      mogli_client = Mogli::Client.create_from_code_and_authenticator(code,authenticator(env_info_hash))
      @access_token = mogli_client.access_token
    rescue Exception => e
      log(e)
      @access_token = nil
    end
  end

  def me()
    if @access_token
      begin
        Mogli::User.find("me",Mogli::Client.new(@access_token))
      rescue Exception => e
        log(e)
        nil
      end  
    end
  end

  def posts(user)
    begin
      user.posts
    rescue Exception => e
      log(e)
      []
    end
  end

  def friends()
    if @access_token
      begin
        return Mogli::User.find("me",Mogli::Client.new(@access_token)).friends.collect { |f| to_member(f)}
      rescue Exception => e
        log(e)
      end
    end
    []
  end

  def post_team_creation(team)
    if @access_token
      begin
        self.class.post(path("me/feed"),:body=>default_params().merge({:message => "Created team #{team.name}"}))
      rescue Exception => e
        log(e)
      end
    end
  end

  private

  def log(e)
    @logger.info(e.message)
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

  def to_member(user)
    @logger.info("Found friend:#{user.name}")
    TeamMember.new(:name => user.name, :facebook_id => user[:id])
  end

end