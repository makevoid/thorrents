# require 'dm-core'
# require 'dm-sqlite-adapter'
# 
# DataMapper.setup :default, "sqlite://#{APP_PATH}/db/app.sqlite"
# 
# 
# Dir.glob("#{APP_PATH}/models/*").each do |model|
#   require model
# end

#require '/Users/makevoid/Sites/voidtools/lib/voidtools'
require 'voidtools'
include Voidtools#::Sinatra::ViewHelpers
include Voidtools::Sinatra::ViewHelpers
#require 'voidtools/sinatra/tracking'
#include Voidtools::Tracking

MIXPANEL_TOKEN = "1838fe8d6e49fd56a030c73c0c58c3d8"



