require 'resque/server'
Lending::Application.routes.draw do

  resources :items do
    collection do
      get :item_history, :show_waiting
    end
  end

  resources :seats do
    collection do
      get :update_status, :reset_seat
    end
  end

  # mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: { :registrations => "registrations", :sessions => "sessions", :passwords => "passwords", :confirmations => "confirmations"}
  devise_scope :user do
    get "admins", to: "sessions#new", :role => "admin"
  end
  root :to => 'home#index'

  mount ChinaCity::Engine => '/china_city'

  mount Resque::Server, :at => "/resque"

  #mount MongodbLogger::Server.new, :at => "/system_logger", :as => :mongodb
  #mount MongodbLogger::Assets.instance, :at => "/system_logger/assets", :as => :mongodb_assets # assets

  resque_web_constraint = lambda do |request|
    current_user = request.env['warden'].user
    current_user.present? && current_user.respond_to?(:is_admin?) && current_user.is_admin?
  end

  constraints resque_web_constraint do
    ResqueWeb::Engine.eager_load!
    mount ResqueWeb::Engine => "/resque_web"
  end

  devise_scope :user do
    resources :registrations do
      collection do
        get :validate_captcha
      end
    end
  end

  # 我要理财
  resources :invests do
    collection do
      get :search
      get :info_json
      get :search_json
      get 'show_invest', 'show_rookie_invest'
      get :rookie_new
      post :create_rookie_bid
    end
  end

  # 债权转让
  resources :debts do
    collection do
      get :debt_json
      get :show_debts
    end
  end


  # 收益计算器
  get 'calculator', to: 'invests#calculator'

  # 我要借款
  get 'loan', to: 'loans#new'

  # 用户来源
  get 'source', to: 'home#source'
  get 'users_source', to: 'home#users_source'

  get 'campaign/:id' => 'campaigns#static'

  namespace :account do

    # 我的账户
    resource :users do
      # 个人主页
      get :show
      get :show_json

      # 实名认证
      get :real_name
      put :request_auth_realname

      # 手机认证
      get :auth_phone

      get :auth_email
      post :confirmation

      # 发送验证码
      get :send_verify_code

      # 验证手机号
      post :verify_phone

      # 个人设置
      get :profile

      get :show_set_password
      get :show_set_trade_password

      post :set_password
      post :set_trade_password
    end

    # 交易记录
    get 'transactions', to: 'cash_flows#index'

    # 充值
    get 'recharge', to: 'pay_orders#new'
    resources :recharges, controller: 'pay_orders' do
      collection do
        get :offline_recharge, :index_offline
        post :create_offline_recharge
      end
      # post 'recharge', to: 'pay_orders#create'

      # # 充值记录
      # get 'recharges', to: 'pay_orders#index'
    end

    # 提现
    resources :withdraws

    # 银行卡管理
    resources :banks, controller: 'user_banks'

    # 理财管理
    resources :invests, controller: 'bids' do
      collection do
        get :stat # 理财统计
        get :repaying
        get :finished
        get :rookie
      end
      member do
        get :contract, :print_contract
      end
    end

    resources :debts do
      collection do
        get :selling_list
        get :sold
      end

      member do
        get :sell
        put :hawk
        put :cancel_hawk
      end
    end

    # 自动投标
    resources :auto_invests

    # 收款明细
    resources :collections

    #协议
    resources :contracts

    #站内消息
    resources :messages

    # 邀请管理
    resources :promotions do
      collection do
        #转盘抽奖结果
        get :circle, :egg, :box, :lucky_code, :lucky_guess, :newyear_egg
        get :spring
        get :two_yr_anniversary
        get :cash, :actual_object, :bribery_money
      end
    end

    #一元购
    resources :yiyuangous do
      collection do
        get :progressing, :waiting, :finished
      end
    end

  end
  namespace :user do
    get 'finish_payment/:id/:pay_class/:notice_from', to: 'payments#finish'
    post 'finish_payment/:id/:pay_class/:notice_from', to: 'payments#finish'
  end
  resources :home, except: [:show] do
    collection do
      get :company_info
      get :info_json
      get :basic_info_json
      get :banner_info
      get :send_verify_code2
      get :confirm_email
      get :source
    end
  end
  resources :guides
  resources :helps
  resources :loan_applications

  resources :webnews

  resources :downloads

  resources :campaigns do
    collection do
      get :circle, :circle_prize, :online, :august, :anniversary, :anniversary_report
      get :september, :anti_japanese, :anti_api, :zhongqiu, :zhongqiu_start, :zhongqiu_end, :zhongqiu_fail
      get :october, :november, :guanggun, :december, :apponline, :double12
      get :lucky_code, :lucky_guess, :huodong_comment, :annual_celebration, :newyear_egg, :newyear_egg_api
      post :update_lucky_code, :create_lucky_guess, :create_huodong_comment
      get :hd20160101
      get :two_yr_anniversary, :two_yr_circle_prize, :two_yr_aug_camp
    end
  end

  namespace :api, defaults: { format: 'json' } do
    resources :banners do
    end
    resources :users
    resources :cash_flows do
      collection do
        get :bids, :repaying, :finished, :stat
      end
    end
    resources :loans do
      collection do
        get :newest
      end
    end
    get "home", to: "home#index"

    devise_scope :user do
      resources :registrations do
        collection do
          get :send_verify_code, :verify_code, :validate_captcha, :verify_mobile
        end
      end
      post "sessions", to: "sessions#create"
      get "sessions/logout", to: "sessions#logout"
    end

    resources :recharges do
      collection do
        get :online_records, :offline_records, :show_banks
        post :create_offline_recharge, :withdraw
        get :withdraw_record, :show_account_bank, :user_info
      end
    end

  end

end
