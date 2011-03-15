require 'haml'
require 'sass'
require 'sinatra'
enable :sessions

path = File.expand_path "../", __FILE__
APP_PATH = path

class App < Sinatra::Base
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

  get '/css/main.css' do
    sass :main
  end
  
end