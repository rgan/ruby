require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../teamsapp.rb'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

describe "teamsapp controller" do

  before :each do
    @browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application, "localhost"))
    Team.stub(:all) { [ Team.new(:name => "team9", :about => "about team1")] }
  end

  describe "home page" do

    it "should get home page" do
      @browser.get '/'
      @browser.last_response.should be_ok
    end

    it "should get all teams" do
      @browser.get '/'
      @browser.last_response.body.should include("team9")
    end

    it "should get facebook user when auth token is present" do
      facebook_service = mock()
      Facebook.stub(:new) { facebook_service }

      facebook_service.stub(:create_access_token_from_code) { "foo" }

      user_mock = mock()
      facebook_service.stub(:me) { user_mock }
      facebook_service.should_receive(:posts)

      user_mock.should_receive(:first_name)
      user_mock.should_receive(:last_name)

      @browser.get '/oauth/create', { :code => "foo"}
      @browser.get '/'
    end
  end

  describe "create team" do

    it "should post to facebook when a team is created" do
      facebook_service = mock()
      Facebook.stub(:new) { facebook_service }

      facebook_service.should_receive(:post_team_creation)
      @browser.post '/team/create', {:name => "team10", :about => "about"}

    end
  end

end