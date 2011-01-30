require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../teamscontroller.rb'
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
  end

  describe "create team" do

    it "should queue updates to activity feeds when a team is created" do
      task_mock = mock()
      AppEngine::Labs::TaskQueue::Task.should_receive(:new).with(nil, {:url => "/worker/post_updates",
                                                                       :method => :POST, :params => {"msg" => "Created team team10",
                                               "windows_access_token" => "",
                                               "fb_access_token" => ""}}).and_return(task_mock)
      task_mock.should_receive(:add)
      @browser.post '/team/create', {:name => "team10", :about => "about"}

    end
  end

end