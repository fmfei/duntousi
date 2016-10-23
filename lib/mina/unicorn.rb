# -*- coding: utf-8 -*-
namespace :unicorn do

  desc "启动 Unicorn"
  task :start => :environment do
    queue 'echo "-----> 启动Unicorn"'
    queue echo_cmd "cd #{deploy_to}/#{current_path} && bundle exec unicorn_rails -D -E production -c #{deploy_to}/#{current_path}/config/unicorn.rb"
  end


  desc "停止 Unicorn"
  task :stop => :environment do
    queue 'echo "-----> 停止Unicorn"'
    queue echo_cmd  "kill -QUIT `cat #{deploy_to}/#{current_path}/tmp/pids/unicorn.pid`"
  end


  desc "重启 Unicorn"
  task :restart => :environment do
    queue 'echo "-----> 重启 Unicorn"'
    queue echo_cmd  "kill -USR2 `cat #{deploy_to}/#{current_path}/tmp/pids/unicorn.pid`"
  end

end
