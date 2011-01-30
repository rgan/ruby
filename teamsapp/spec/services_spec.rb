require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../services/google.rb'
require File.dirname(__FILE__) + '/../services/windows_live.rb'

describe "windows live" do

  it "should return authorize url" do
    WindowsLive.new(APP_INFO[APP_ENV]).authorize_url().should ==
        "https://consent.live.com/Connect.aspx?wrap_client_id=0000000048046F22&wrap_callback=https://teamsappdemo.appspot.com/&wrap_scope=WL_Contacts.View,WL_Profiles.View,WL_Activities.Update"
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
end

describe "google" do

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
end

describe "facebook" do
  it "should parse user data" do
    user = Facebook.new().to_user(facebook_user_data)
    user.first_name.should == "foo"
    user.last_name.should == "bar"
    user.fb_id.should == "2000"
  end

  it "should parse posts" do
    posts = Facebook.new().to_posts(posts_data)
    posts.size().should == 1
    posts[0].message.should == "Created team team5"
    posts[0].updated_time.should == "2011-01-24T15:30:24+0000"
  end

  it "should parse friends" do
    friends = Facebook.new().to_friends(friends_data)
    friends.size().should == 2
    friends[0].name.should == 'John Smith'
  end
  
end


  def facebook_user_data()
<<EOF
{"id":"2000","name":"Foo bar","first_name":"foo","last_name":"bar"}
EOF
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

  def posts_data()
<<EOF
{
   "data": [
      {
         "id": "1234_104583179617685",
         "from": {
            "name": "Foobar",
            "id": "22222"
         },
         "message": "Created team team5",
         "actions": [
            {
               "name": "Comment",
               "link": "http://www.facebook.com/1234/posts/104583179617685"
            },
            {
               "name": "Like",
               "link": "http://www.facebook.com/1234/posts/104583179617685"
            }
         ],
         "privacy": {
            "description": "Friends Only",
            "value": "ALL_FRIENDS"
         },
         "type": "status",
         "created_time": "2011-01-24T15:30:24+0000",
         "updated_time": "2011-01-24T15:30:24+0000",
         "attribution": "Teams"
      }
   ],
   "paging": {
      "previous": "https://graph.facebook.com/me/feed?access_token=2227470867\u00257C2._bpjFNPS5vx0JjNNFD4iBA__.3600.1296280800-100001569193092\u00257CVvFwWOY6H5er42cMv6P8eSKh_zk&limit=25&since=2011-01-24T15\u00253A30\u00253A24\u00252B0000",
      "next": "https://graph.facebook.com/me/feed?access_token=2227470867\u00257C2._bpjFNPS5vx0JjNNFD4iBA__.3600.1296280800-100001569193092\u00257CVvFwWOY6H5er42cMv6P8eSKh_zk&limit=25&until=2011-01-19T20\u00253A33\u00253A48\u00252B0000"
   }
}
EOF
  end

def friends_data()
  <<EOF
{"data":[{"name":"John Smith","id":"100001956111138"},{"name":"Lorem Nag","id":"z123456"}]}
EOF
end
