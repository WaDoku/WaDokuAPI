# -*- encoding : utf-8 -*-
require "bundler/capistrano"
require "capistrano/ext/multistage"
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_type, :system  # Copy the exact line. I really mean :system here
set :normalize_asset_timestamps, false

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :application, "WadokuAPI"
set :repository,  "git://github.com/Wadoku/WaDokuAPI.git"

server_ip = "rokuhara.japanologie.kultur.uni-tuebingen.de"

role :web, server_ip                          # Your HTTP server, Apache/etc
role :app, server_ip                          # This may be the same as your `Web` server
role :db,  server_ip, :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

options[:pty] = true
ssh_options[:forward_agent] = true
default_run_options[:pty] = true
set :deploy_via, :remote_cache
set :user, "deploy"
set :use_sudo, false
set :git_enable_submodules, 1
set :keep_releases, 2

namespace :index do
  task :reindex do
    run "cd #{current_path} && bundle exec ruby index.rb"
  end
end

namespace :deploy do
  task :start, :roles => :app  do 
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop do ; end

  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :fix_ownership, :roles => :app do
    run "chown -R deploy:www-data #{deploy_to}"
  end
end

namespace :db_setup do
  task :create_shared, :roles => :app do
    run "mkdir -p #{deploy_to}/#{shared_dir}/db/"
    run "chmod 1777 #{deploy_to}/#{shared_dir}/db/"
    run "mkdir -p #{deploy_to}/#{shared_dir}/index/"
    run "chmod -R 1777 #{deploy_to}/#{shared_dir}/index/"
  end

  task :link_shared do
    run "rm -rf #{release_path}/db/sqlite"
    run "ln -nfs #{shared_path}/db #{release_path}/db/sqlite"
    run "rm -rf #{release_path}/index"
    run "ln -nfs #{shared_path}/index #{release_path}/index"
  end
end

namespace :rake do
  desc "Invoke rake task"
  task :invoke do
    run "cd #{current_path} && bundle exec rake #{ENV['task']} RAILS_ENV=#{rails_env} --trace"
  end
end

after "deploy:update_code", "db_setup:link_shared"
after "deploy:setup", "db_setup:create_shared"
after "deploy:update_code", "deploy:fix_ownership"
after "deploy:update_code", "deploy:cleanup"
after "rake:invoke", "deploy:fix_ownership"
