# -*- coding: utf-8 -*-
$:.unshift './lib'

require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rvm'    # for rvm support. (http://rvm.io)

require 'mina/unicorn'
require 'mina/resque'


Dir['lib/mina/servers/*.rb'].each { |f| load f }

###########################################################################
# 对所有服务器通用的设置
###########################################################################

set :app,                'lending'
set :repository,         'git@bitbucket.org:weigang992003-admin/zr_p2p.git'
set :keep_releases,       5
set :default_server,     :aliyun
set :shared_paths, ['config/database.yml',
                    'config/unicorn.rb',
                    'log',
                    'config/cus_env.rb',
                    'config/resque.god',
                    'public/uploads',
                    'tmp',
                    'public/system',
                    'public/images/cache']

# 设置部署的服务器
set :server, ENV['to'] || default_server
invoke :"server:#{server}"

# 项目的 Rails Root Path
set :pro_root_path, "#{deploy_to}/#{current_path}"

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/system"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/system"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/images/cache"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/images/cache"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    #queue echo_cmd "bundle exec rake seed_data:all"

    to :launch do
      # invoke :'resque:start_god'
      invoke :'resque:restart'
      invoke :'resque:restart_scheduler'
      invoke :'unicorn:restart'
    end
  end
end