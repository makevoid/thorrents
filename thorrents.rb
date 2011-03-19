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

  get '/search/*' do |query|
    content_type :json
    results = []

    unless query==""
      thor = Thorz.new query
      thor.search
      results = thor.results
    end if ENV['RACK_ENV'] == "production"
    
    callback = request.params["callback"]
    if callback.blank?
      { results: results }.to_json
    else
      "#{callback}("+ { results: results }.to_json + ')'
    end
  end  

  get '/css/main.css' do
    sass :main
  end
  
end