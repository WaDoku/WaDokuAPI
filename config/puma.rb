tag 'WaDokuAPI-STAGING'
environment 'staging'
bind 'tcp://127.0.0.1:10012'
workers 4
preload_app!

state_path '/var/www/staging/wadoku_api/current/tmp/pids/puma.state'
pidfile '/var/www/staging/wadoku_api/current/tmp/pids/puma.pid'
activate_control_app 'unix:///var/run/wadoku_api_staging_pumactl.sock'
