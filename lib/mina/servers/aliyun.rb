namespace :server do
  task :aliyun => [:environment] do
    set :branch,              'develop'
    set :domain,              '123.57.42.111'
    set :port,                '22'
    set :deploy_to,           '/var/www/p2p'
    set :user,                'zhongrong'
    set :rails_env,           'production'

    invoke :"rvm:use[ruby-2.2.1]"
  end
end
