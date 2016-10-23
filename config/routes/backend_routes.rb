# encoding: utf-8
Lending::Application.routes.draw do
  namespace :backend do

    resources :home
    resources :password
    resources :admins
    get 'invites', to: 'invites#index'
    resources :users do
      collection do
        post :create_user_info
      end
      member do
        get :change_avatar
      end
      resources :identifications do
      end
    end
    resources :loans do
      member do
        post :submit_audit
      end
    end
    resources :rookie_loans do
      member do
        post :submit_audit
        get :senior_audit
        get :detail
      end
    end
    resources :audits do
      member do
        get :junior_audit
        get :senior_audit
        get :details
        post :junior_audit_pass
        post :senior_audit_pass
        post :start_bidding
        post :bids_auditing_pass
        post :fail_bid
        post :cut_off
      end
    end
    resources :roles do
      collection do
        get :edit_multiple
        put :update_multiple
      end
    end

    resources :permissions
    resources :propagandas
    resources :articles
    resources :friendlinks do
      collection do
        post :set_weight
      end
    end
    resources :bids do
      collection do
        get :belongs_to_loan
        get :selling, :sold
      end
    end
    resources :web_statistics do
      collection do
        get :investment_statistics
        get :bid_statistics
        get :borrow_statistics
        get :fund
        get :remainder
      end
    end
    resources :lenders do
      collection do
        #get :auth_realname_pass
        get :branch
      end
    end
    resources :advance_lenders do
      collection do
        get :auth_realname_pass
        get :export_users
        get :show_loan_invest_info
      end
      member do
        patch :modify
        patch :change_pass
        post :create_coupon
      end
    end

    resources :cash_flows do
      collection do
        get :stat
      end
    end
    resources :messages

    resources :pay_orders do
      collection do
        get :manage, :modify_addition
        get :backend_recharge, :backend_recharges, :deduct, :deducts
        post :create_backend_recharge, :download, :create_deduct, :update_addition
      end
    end

    # 提现处理
    resources :withdraws do
      member do
        post :set_notice
      end
      collection do
        post :download
      end
    end

    resources :loan_applications do
      collection do
        post :download
      end
    end

    resources :repayments

    # 协议
    resources :protocols
    # get 'protocol/:type', to: 'protocols#show', as: 'protocol'

    resources :system_configs do
      collection do
        get :site_avaliable, :promotion, :prize
        post :close_site
        put :update_promotion, :update_prize
      end
    end

    resources :banners do
      collection do
        post :set_weight
      end
    end

    resources :auto_invest_rules do
      collection do
        post :execute
        get :stats
      end
    end

    resources :downloads

    resources :auth_mobiles

    resources :auth_realnames

    resources :organizations

    resources :offline_banks do
    end

    resources :offline_recharges do
      collection do
        get :wait_audit
      end
    end

    resources :promotions do
      collection do
        get :circle, :circle_excel
        get :egg
        get :lucky_code, :consolation_prize, :lucky_guess, :huodong_comment, :newyear_egg
        post :create_lucky_code, :create_lucky_guess, :create_huodong_comment
        get :two_yr_anniversary, :two_yr_anniversary_no_use
        get :activies, :bonu, :add_delivery_num
        post :create_bonu, :create_delivery_num
      end
    end

    resources :products do
      collection do
        get :index
        post :create_product, :draw_lottery
        get :items_list, :product_orders
      end
    end

    resources :attachements do
      collection do
        get :new
        post :create_attachement, :main_pic
      end
    end

  end

end
