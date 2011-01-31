require File.dirname(__FILE__) + '/spec_helper.rb'
require File.dirname(__FILE__) + '/../services/facebook.rb'

describe "facebook" do

  it "should return authorize url" do
    Facebook.new().authorize_url(APP_INFO["test"]).should == "https://graph.facebook.com/oauth/authorize?client_id=123456&redirect_uri=https%3A%2F%2Fteamsapptest.appspot.com%2F%2Foauth%2Fcreate&scope=publish_stream,read_stream&display=page"
  end

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

  it "should return me from cache" do
    memcache = AppEngine::Memcache.new
    svc = Facebook.new("accesstoken", memcache)
    memcache.add(svc.memcache_key("me"), "expected response", 10)
    svc.get_response("url", {}).should == "expected response"
  end

  it "should put response from me in cache" do
    memcache = AppEngine::Memcache.new
    svc = Facebook.new("accesstoken", memcache)
    mock_response = mock()
    mock_response.stub(:body) {"expected response"}
    Facebook.stub(:get) { mock_response }
    svc.get_response("url", {})
    memcache.get(svc.memcache_key("me")).should == "expected response"
  end

end


  def facebook_user_data()
<<EOF
{"id":"2000","name":"Foo bar","first_name":"foo","last_name":"bar"}
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
