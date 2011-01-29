require 'sinatra'
require 'appengine-apis/urlfetch'
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
    windows_live = WindowsLive.new()
    session[:windows_acess_token] = windows_live.access_token(APP_INFO[APP_ENV], params[:wrap_verification_code])
    @win_live_contacts = windows_live.contacts(APP_INFO[APP_ENV][:windows_live_client_id], session[:windows_acess_token])
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
  redirect WindowsLive.new().authorize_url(APP_INFO[APP_ENV][:windows_live_client_id], APP_INFO[APP_ENV][:url])
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
    Facebook.new(session[:fb_access_token]).post_team_creation(team)
    redirect '/'
  else
    @errors = team.errors.full_messages
    erb :"team/new"
  end
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