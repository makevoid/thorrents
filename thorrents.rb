require 'haml'
require 'sass'
require 'sinatra'
require 'json'
enable :sessions

path = File.expand_path "../", __FILE__
APP_PATH = path

class NilClass
  def blank?
    self.nil?
  end
end

class String
  def blank?
    self.nil? || self == ""
  end
end

FB_APP_ID = "192114967494018"

require "#{APP_PATH}/models/thorz"

class Thorrents < Sinatra::Base
  require "#{APP_PATH}/config/env"
  
  set :haml, { :format => :html5 }
  require 'rack-flash'
  enable :sessions
  use Rack::Flash
  require 'sinatra/content_for'
  helpers Sinatra::ContentFor
  set :method_override, true

  def not_found(object=nil)
    halt 404, "404 - Page Not Found"
  end

  get "/" do
    haml :index
  end

  get "/docs" do
    haml :docs
  end
  
  get "/recommended_clients" do
    haml :recommended_clients
  end
  
  def load_results    
    query = params[:query]
    
    results = []
    unless query==""
      thor = Thorz.new query
      thor.search
      results = thor.results
    end if ENV['RACK_ENV'] == "production"
    results
  end

  get '/search/:query.json' do 
    results = load_results

    content_type :json
    callback = request.params["callback"]
    if callback.blank?
      { results: results }.to_json
    else
      "#{callback}("+ { results: results }.to_json + ')'
    end
  end  
  
  get '/search*' do |query|
    @query = params[:query] = query.gsub(/^\//, '')
    @results = load_results

    haml :result    
  end  

  get '/css/main.css' do
    sass :main
  end
  
end