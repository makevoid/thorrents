require 'haml'
require 'sass'
require 'sinatra'
require 'json'
enable :sessions

path = File.expand_path "../", __FILE__
APP_PATH = path


# monkeypatching

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

module KeysSymbolizer
  def symbolize_keys!
    self.replace(self.symbolize_keys)
  end
  
  def symbolize_keys
    inject({}) do |options, (key, value)|
      options[(key.to_sym rescue key) || key] = value
      options
    end
  end
  
  def recursive_symbolize_keys!
    symbolize_keys!
    # symbolize each hash in .values
    values.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    # symbolize each hash inside an array in .values
    values.select{|v| v.is_a?(Array) }.flatten.each{|h| h.recursive_symbolize_keys! if h.is_a?(Hash) }
    self
  end
end

class Hash
  include KeysSymbolizer
end

# app

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
  
  helpers do
    def search_title
      " search: #{CGI.escape $1}" if request.path =~ /^\/search\/(.+)/
    end
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
      results = if ENV['RACK_ENV'] == "production"
        thor = Thorz.new query
        thor.search
        thor.results
      else
        [{name: "antani", magnet: "#link", seeds: "2"}, {name: "sblinda", magnet: "#link", seeds: "1"}]
      end
    end 
    
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