
set :application, "thorrents"

#set :domain, "kim.makevoid.com" # old: krikri.makevoid.com
set :domain,      "makevoid.com"

# git

# #set :repository,  "svn://#{domain}/svn/#{application}"
# #default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :repository, "git://github.com/makevoid/thorrents.git"  # public

set :scm, "git"
set :branch, "master"
set :deploy_via, :remote_cache

set :password, File.read(File.expand_path "~/.password").strip.gsub(/33/, '')


set :user,        "www-data"

set :use_sudo,    false
set :deploy_to,   "/www/#{application}"

role :app, domain
role :web, domain
role :db,  domain, :primary => true




after :deploy, "deploy:cleanup"
#after :deploy, "db:seeds"
after :deploy, "deploy:newrelic_secret"

namespace :deploy do
  
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  desc "Setup newrelic license key"
  task :newrelic_secret do
    newrelic_key = File.read(File.expand_path '~/.newrelic').strip
    run "ruby -e \"path = '#{current_path}/config'; db_yaml = File.read(path+'/newrelic.yml'); File.open(path+'/newrelic.yml', 'w'){ |f| f.write db_yaml.gsub(/LICENSE_KEY/, '#{newrelic_key}') }\""
  end
end

namespace :bundle do
  desc "Install gems with bundler"
  task :install do
    run "cd #{current_path}; bundle install --relock"
  end
  
  desc "Commit, deploy and install"
  task :installscom do
    `svn commit -m ''`
    `cap deploy`
    `cap bundle:install`
  end
end

# ...

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
  
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
  
  task :lock, :roles => :app do
    run "cd #{current_release} && bundle lock;"
  end
  
  task :unlock, :roles => :app do
    run "cd #{current_release} && bundle unlock;"
  end
end

# HOOKS
after "deploy:update_code" do
  bundler.bundle_new_release
  # ...
end

R_ENV = "RACK_ENV"

namespace :scraper do
  desc "Run the scraper"
  task :scrape do
    run "cd #{current_path}; #{R_ENV}=production bundle exec rake scraper:scrape --trace"
  end
end


namespace :db do
  desc "Create database"
  task :create do
    run "mysql -u root --password=#{password} -e 'CREATE DATABASE IF NOT EXISTS #{application}_production;'"
  end
  
  desc "Seed database"
  task :seeds do
    run "cd #{current_path}; #{R_ENV}=production rake db:seeds"
  end
  
  desc "Migrate database"
  task :automigrate do
    run "cd #{current_path}; #{R_ENV}=production rake db:automigrate --trace"
  end
  
  desc "Send the local db to production server"
  task :toprod do
    # `rake db:seeds`
    `mysqldump -u root #{application}_development > db/#{application}_development.sql`
    upload "db/#{application}_development.sql", "#{current_path}/db", :via => :scp
    run "mysql -u root --password=#{password} #{application}_production < #{current_path}/db/#{application}_development.sql"
  end
  
  desc "Get the remote copy of production db"
  task :todev do
    run "mysqldump -u root --password=#{password} #{application}_production > #{current_path}/db/#{application}_production.sql"
    download "#{current_path}/db/#{application}_production.sql", "db/#{application}_production.sql"
    local_path = `pwd`.strip
    `mysql -u root #{application}_development < #{local_path}/db/#{application}_production.sql`
  end
end

