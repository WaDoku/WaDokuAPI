tag 'WaDokuAPI-STAGING'
environment 'staging'
bind 'tcp://127.0.0.1:10012'
workers 4
preload_app!

state_path '/var/www/staging/wadoku_api/current/tmp/pids/puma.state'
pidfile '/var/www/staging/wadoku_api/current/tmp/pids/puma.pid'