server "103.244.9.7", :app, :web, :db, :primary => true
set :rails_env, "staging"
set :user, 'app'
set :branch, :master
set :deploy_to, "/home/app/www/figoeyewear"

default_run_options[:pty] = true
set :default_environment, {
  'PATH' => "/home/app/.rbenv/shims:/home/app/.rbenv/bin:$PATH"
}