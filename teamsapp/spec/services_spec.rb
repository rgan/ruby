require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../services/google.rb'

describe "google" do

  it "should create request token" do
    Google.new().request_token("https://teamsappdev.appspot.com").should_not be_nil
  end

  it "should parse contacts from valid json" do
    members = Google.new().to_members(contacts_json())
    members.size().should == 3
    members[0].name.should == "Elizabeth Bennet"
    members[0].google_id.should == "user1ID"
  end

  it "should return no members from invalid json" do
    members = Google.new().to_members("400 :HTTPBadRequest")
    members.size().should == 0
  end

  def contacts_json
<<EOF
{
"startIndex": 0,
"totalResults": 3,
"entry": [
  {
    "profileUrl": "http://www.google.com/s2/profiles/user1ID",
    "isViewer": true,
    "id": "user1ID",
    "thumbnailUrl": "http://www.google.com/s2/photos/private/photo1ID",
    "name": {
      "formatted": "Elizabeth Bennet",
      "familyName": "Bennet",
      "givenName": "Elizabeth"
    },
    "urls": [
      {
        "value": "http://www.google.com/s2/profiles/user1ID",
        "type": "profile"
      }
    ],
    "photos": [
      {
        "value": "http://www.google.com/s2/photos/private/photo1ID",
        "type": "thumbnail"
      }
    ],
    "displayName": "Elizabeth Bennet"
  },
  {
    "profileUrl": "http://www.google.com/s2/profiles/user2ID",
    "id": "user2ID",
    "name": {
      "familyName": "Darcy",
      "givenName": "Fitzwilliam"
    },
    "urls": [
      {
        "value": "http://www.google.com/s2/profiles/user2ID",
        "type": "profile"
      }
    ],
    "displayName": "darcy@gmail.com"
  },
  {
    "name": {
      "formatted": "Jane Bennet"
    },
    "displayName": "Jane Bennet"
  }
],
"requestUrl": "requestUrl"
}
EOF
    end

end