require 'sinatra'
require 'appengine-apis/urlfetch'
require 'appengine-apis/labs/taskqueue'
Net::HTTP = AppEngine::URLFetch::HTTP
require 'dm-core'
require 'dm-validations'
require 'models/team'
require 'models/team_member'
require 'services/facebook'
require 'services/google'
require 'services/windows_live'
require 'oauth'

require 'env.rb'

DataMapper.setup(:default, "appengine://auto")
DataMapper.repository.adapter.singular_naming_convention!

enable :sessions

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

get '/' do
  @teams = Team.all
  if session[:fb_access_token]
    facebook = Facebook.new(session[:fb_access_token])
    @user = facebook.me()
    session[:fb_access_token] = nil if @user.nil?
    @posts = facebook.posts() unless @user.nil?
  end
  if session[:google_request_token] && params[:oauth_verifier]
    @google_contacts = Google.new().contacts(session[:google_request_token], params[:oauth_verifier])
  end
  if params[:wrap_verification_code]
    session[:windows_access_token] = WindowsLive.new(APP_INFO[APP_ENV]).access_token(params[:wrap_verification_code])
  end
  if session[:windows_access_token]
    @win_live_contacts = WindowsLive.new(APP_INFO[APP_ENV]).contacts(session[:windows_acess_token])
  end
  erb :index
end

get '/facebook_login' do
  session[:fb_access_token]=nil
  redirect Facebook.new().authorize_url(APP_INFO[APP_ENV])
end

get '/oauth/create' do
  session[:fb_access_token]= Facebook.new().create_access_token_from_code(params[:code], APP_INFO[APP_ENV])
  redirect "/"
end

get '/google_login' do
  session[:google_request_token] = Google.new().request_token(APP_INFO[APP_ENV][:url])
  if session[:google_request_token]
    redirect session[:google_request_token].authorize_url()
  end
end

get '/windows_login' do
  redirect WindowsLive.new(APP_INFO[APP_ENV]).authorize_url()
end

get '/team/new' do
  erb :"team/new"
end

get '/team/:id' do
  @team = Team.get(params[:id])
  erb :"team/view"
end

get '/team/:id/member/new' do
  @team = Team.get(params[:id])
  @candidates = @team.candidates(Facebook.new(session[:fb_access_token]).friends())
  erb :"team/new_member"
end

post '/team/create' do
  team = Team.new(:name => params[:name], :about => params[:about])
  if team.save
    queue_social_updates("Created team #{team.name}")
    redirect '/'
  else
    @errors = team.errors.full_messages
    erb :"team/new"
  end
end

post '/worker/post_updates' do
  Facebook.new(params[:fb_access_token]).post_update(params[:msg])
  WindowsLive.new(APP_INFO[APP_ENV]).post_update(params[:windows_acess_token], params[:msg])
end

post '/team/:id/member/create' do
  @errors = []
  @team = Team.get(params[:id])
  @candidates = @team.candidates(Facebook.new(session[:fb_access_token]).friends())
  if nil_or_empty?(params[:name]) && nil_or_empty?(params[:selected_member])
    @errors << "must select from list or provide name"
    erb :"team/new_member"
  else
    name = member_name_from_params(params)
    @errors = @team.add_member(name)
    if @errors.size > 0
      erb :"team/new_member"
    else
      redirect "/team/#{@team.id}"
    end
  end
end

def nil_or_empty?(v)
  v.nil? || v.empty?
end

def member_name_from_params(params)
  if !nil_or_empty?(params[:selected_member])
    params[:selected_member]
  else
    params[:name]
  end
end

def queue_social_updates(msg)
  windows_token = session[:windows_access_token].nil? ? "" : session[:windows_access_token].access_token
  fb_token = session[:fb_access_token].nil? ? "" : session[:fb_access_token]
  AppEngine::Labs::TaskQueue::Task.new(nil, {:url => "/worker/post_updates", :method => :POST, :params => {"msg" => msg,
                                               "windows_access_token" => windows_token,
                                               "fb_access_token" => fb_token}}).add
end