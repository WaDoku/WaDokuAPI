# -*- encoding : utf-8 -*-
require "bundler/capistrano"
require "capistrano/ext/multistage"
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_type, :system  # Copy the exact line. I really mean :system here

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :application, "WadokuAPI"
set :repository,  "git://github.com/Wadoku/WaDokuAPI.git"

server_ip = "192.168.2.105"

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
