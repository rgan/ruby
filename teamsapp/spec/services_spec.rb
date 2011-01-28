require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../services/google.rb'
require File.dirname(__FILE__) + '/../services/windows_live.rb'

describe "services" do

  it "should return authorize url" do
    WindowsLive.new().authorize_url(APP_INFO[APP_ENV][:windows_live_client_id], APP_INFO[APP_ENV][:url]).should ==
        "https://consent.live.com/Connect.aspx?wrap_client_id=0000000048046F22&wrap_callback=https://teamsappdemo.appspot.com/&wrap_scope=WL_Contacts.View"
  end

  it "should parse token from response" do
    token = WindowsLive.new().token_from_response("wrap_access_token=1234BZ%3d&wrap_access_token_expires_in=60&wrap_refresh_token=A2345")
    token.access_token.should == "1234BZ="
    token.refresh_token.should == "A2345"
    token.expires_in.should == "60"
  end

  it "should parse windows live contacts response with no entries" do
    contacts = WindowsLive.new().to_contacts('{"BaseUri":"https:\/\/apis.live.net\/V4.1\/cid-0000000048046F22\/","Entries":[],"SelfLink":"Contacts\/AllContacts"}')
    contacts.size().should == 0
  end

  it "should parse windows live contacts response with entries" do
    contacts = WindowsLive.new().to_contacts(windows_live_contacts_json())
    contacts.size().should == 1
    contacts[0].name.should == "Hotmail Team"
    contacts[0].windows_id.should == "urn:uuid:5TVJ52O2CL5EPJWZNYE7KT7QUU"
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

  def windows_live_contacts_json()
<<EOF
{
"BaseUri": "http://bay.apis.live.net/V4.1/cid-ECA65CC6F70DD163/",
"Entries": [ // 1 items
{
"BaseUri": "http://bay.apis.live.net/V4.1/cid-ECA65CC6F70DD163/",
"ETag": "2011-01-28T08:49:02.8230000",
"Id": "urn:uuid:5TVJ52O2CL5EPJWZNYE7KT7QUU",
"SelfLink": "Contacts/AllContacts/5TVJ52O2CL5EPJWZNYE7KT7QUU",
"Title": "Hotmail Team",
"Updated": "/Date(1296233342823)/",
"Emails": [ // 1 items
{
"Type": 0
}
],
"FirstName": "Hotmail Team",
"FormattedName": "Hotmail Team"
}
],
"SelfLink": "Contacts/AllContacts"
}
EOF


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