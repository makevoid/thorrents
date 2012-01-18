require 'haml'
require 'sass'
require 'sinatra/base'
# require "sinatra/reloader"
require 'json'
require 'net/https'

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

class String
  def titleize
    # self.split("_").map{ |w| w.capitalize }.join(" ").capitalize
    self.split("_").join(" ").capitalize
  end
  
  def urlize
    # js: self.replace(/[^a-z0-9]+/gi, " ").trim().replace(/\s/g, "_").toLowerCase()
    self.gsub(/[^a-z0-9]+/i, ' ').strip.gsub(/\s/, "_").downcase
  end
end

class NilClass
  def titleize
    nil
  end
  
  def urlize
    nil
  end
end


# app

FB_APP_ID = "192114967494018"

require 'mixpanel'

require 'newrelic_rpm'


require "#{APP_PATH}/models/thorz"

class Thorrents < Sinatra::Base
  require "#{APP_PATH}/config/env"
  
  HOST = "thorrents.com"
  
  configure :development do
    # register Sinatra::Reloader
    # also_reload %w(controllers models config lib).map{|f| "#{f}/*.rb" }
    set :public_folder, "public"
    set :static, true
  end
  
  set :haml, { :format => :html5 }
  # enable :sessions
  # require 'rack-flash'
  # use Rack::Flash
  require 'sinatra/content_for'
  helpers Sinatra::ContentFor
  set :method_override, true

  def not_found(object=nil)
    halt 404, "404 - Page Not Found"
  end
  
  
  # mixpanel

  def initialize_mixpanel
    @mixpanel = Mixpanel::Tracker.new(MIXPANEL_TOKEN, request.env, true) if request.host == HOST
  end

  def track(event, properties={})
    initialize_mixpanel if @mixpanel.nil?
    @mixpanel.track_event event, properties unless ENV["RACK_ENV"] == "development" || request.host != HOST
  end
  
  
  helpers do    
    def in_search
      /^\/search\/(.+)/
    end
    
    def meta_description
      request.path =~ in_search ? "Download thorrent with magnet link!" : "Thorrents is a search engine for magnet links that uses TPB as a source! Now you can share your favourite magnet links via Facebook!"
    end
    
    def search_title
      if request.path =~ in_search
        " search: #{CGI.escape $1}" 
      else
        " - Smash old fashioned HTTP downloaders! Thor agrees!"
      end
    end
  end
  
  before do 
    headers "Access-Control-Allow-Origin" => "*"
  end
  

  get "/" do
    track :page, name: "index", mp_note: "User viewed the index page"
    haml :index
  end

  get "/docs" do
    track :page, name: "docs", mp_note: "User viewed docs"
    haml :docs
  end
  
  get "/recommended_clients" do
    haml :recommended_clients
  end
  
  def load_results    
    results = []
    
    unless @query.blank?
      thor = Thorz.new @query
      thor.search
      # thor.proxied_search if ENV["RACK_ENV"] == "development"
      results = thor.results
    end 
    
    results    
  end
  
  def https(url)
    uri = URI.parse url 
    http = Net::HTTP.new uri.host, uri.port 
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new uri.request_uri 
    response = http.request request 
  end
  
  
  get '/search/:query.json' do 
    @query = params[:query]
    results = load_results

    content_type :json
    callback = request.params["callback"]
    if callback.blank?      
      track :query, name: @query, type: "json", mp_note: "User searched '#{@query}' via json"
      { results: results }.to_json
    else
      "#{callback}("+ { results: results }.to_json + ')'
    end
  end  
  
  get '/search*' do |query|
    query = query.gsub(/^\//, '')
    @query, @result = query.split "/"
    @results = load_results
    
    if request.user_agent =~ /facebook/ || params[:fb]
      url = "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=1&imgsz=medium&q=#{@query.gsub(/\s/, "%20")}"
      response = https(url)
      json = JSON.parse(response.body)
      @fb_image = json["responseData"]["results"].first["url"]
    end
    
    track :query, name: @query, type: "html", mp_note: "User searched '#{@query}' via html"
    haml :result    
  end  

  get '/css/main.css' do
    sass :main
  end
  
end