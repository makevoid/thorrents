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

require "#{APP_PATH}/models/thorz"

class Thorrents < Sinatra::Base
  require "#{APP_PATH}/config/env"

  HOST = "localhost:3000"

  configure :development do
    set :public_folder, "public"
    set :static, true
  end

  set :haml, { :format => :html5 }
  set :method_override, true

  def not_found(object=nil)
    halt 404, "404 - Page Not Found"
  end

  helpers do
    def in_search
      /^\/search\/(.+)/
    end

    def meta_description
      request.path =~ in_search ? "Download thorrent with magnet link!" : "Thorrents is a social magnet links search engine. Now you can share music/movies/software with your friends! Remember to buy things if you like them!"
    end

    def search_title
      if request.path =~ in_search
        " search: #{CGI.escape $1}"
      else
        " - Smash old fashioned HTTP downloaders! Thor agrees!"
      end
    end
  end


  # hooks

  before do
    headers "Access-Control-Allow-Origin" => "*"
  end

  # TODO: use function instead of hook as it will be faster - or switch to roda


  # routes

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
    unless @query.blank?
      thor = Thorz.new @query
      thor.search
      thor.results
    end || []
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

    #content_type :json
    content_type "application/javascript"
    callback = request.params["callback"]
    if callback.blank?
      { results: results }.to_json
    else
      "#{callback}("+ { results: results }.to_json + ')'
    end
  end

  get '/search*' do |query|
    query = query.gsub(/^\//, '')
    @query, @result = query.split "/"
    @results = load_results

    @query.gsub!(/_+/, ' ')

    haml :result
  end

  # TODO: move search route up for speed

  # NOTE: this was an interesting idea:
  # def load_results_alt
  #   unless @query.blank?
  #     thor = Thorz.new @query
  #     thor.proxied_search if ENV["RACK_ENV"] == "development"
  #     thor.results
  #   end || []
  # end

end
