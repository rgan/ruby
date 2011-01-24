require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../models/team.rb'
require File.dirname(__FILE__) + '/../models/team_member.rb'

describe "team" do

  before :each do
    AppEngine::Testing.install_test_datastore
  end

  it "should require name" do
    team = Team.new()
    team.valid?.should be_false
    team.errors.full_messages[0].should == "Name must not be blank"
  end

  it "should require about" do
    team = Team.new(:name=> "test")
    team.valid?.should be_false
    team.errors.full_messages[0].should == "About must not be blank"
  end

  it "should save team if valid" do
    team = Team.new(:name=> "test", :about => "about")
    team.valid?.should be_true
    team.save.should be_true
    Team.all(:name => "test").size().should == 1
  end

  it "should save team member" do
    team = Team.new(:name=> "test", :about => "about")
    team.add_member("member1")
    team = Team.first(:name => "test")
    team.team_members.size().should == 1
    TeamMember.all(:name => "member1").size().should == 1
  end

  it "should return candidates that are not in the team" do
    team = Team.new(:name=> "test", :about => "about")
    TeamMember.new(:name => "member1").save
    team.candidates(TeamMember.all).size().should == 1
  end

  it "should not return candidates that are already in the team" do
    team = Team.new(:name=> "test", :about => "about")
    team.add_member("member1")
    team.candidates(TeamMember.all).size().should == 0
  end
  
end

describe "team member" do

  it "should require name" do
    team_member = TeamMember.new()
    team_member.valid?.should be_false
    team_member.errors.full_messages[0].should == "Name must not be blank"
  end
  
end
