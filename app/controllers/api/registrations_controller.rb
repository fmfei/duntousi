# encoding: utf-8
class Api::RegistrationsController < Devise::RegistrationsController

  skip_before_action :verify_authenticity_token, if: lambda { |controller| controller.request.format.json? }
  respond_to :html, :json


  ##
  # 用户注册
  #
  # POST /api/registrations.json
  #
  # params:
  #
  #  user[mobile]
  #  user[password]
  #  verify_code
  #
  # 返回结果：
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "id": 91,
  #         "email": "",
  #         "created_at": "2015-12-09T18:34:37.867+08:00",
  #         "updated_at": "2015-12-09T18:34:37.904+08:00",
  #         "encrypted_trade_password": null,
  #         "auth_mobile": true,
  #         "auth_realname": null,
  #         "from_user_id": null,
  #         "mobile": "131212233333",
  #         "branch": null,
  #         "register_ip": null,
  #         "source": null,
  #         "channel": null,
  #         "authentication_token": "NJzb2iGqmgWUtpUqB36z"
  #     }
  #  }
  def create
    redis = Redis.new
    verify_code = redis.get params[:user][:mobile]
    if params[:verify_code] == verify_code || !Utils.production?
      resource = User.create(:mobile => params[:user][:mobile], :password=>params[:user][:password])
      resource.roles << Role.find_by_name('投资人')
      resource.from_user_id = cookies[:from_user]
      resource.source = cookies[:source]
      resource.channel = cookies[:channel]
      resource.auth_mobile = true
      resource.save
      if resource.errors.present?
        if resource.errors[:mobile] == ["号码已存在"]
          @message = '此用户已注册。'
        else
          @message = resource.errors
        end
        @status = 1
        render 'layouts/api', layout: false
        return
      else
        sign_in(resource_name, resource)
        @data = resource
        render 'layouts/api', layout: false
        return
      end

    else
      @message = '验证码错误或过期，请重新注册。'
      @status = 0
      render 'layouts/api', layout: false
    end
  end

  ##
  # 发送注册短信验证码
  #
  # GET /api/registrations/send_verify_code.json
  #
  # params:
  #  mobile
  #
  # Example
  #
  #  resp = get 'http://localhost:3000/api/registrations/send_verify_code?mobile=13121223780'
  #
  # 返回结果
  #  {
  #     "status": 1,
  #     "message": "success"
  #  }
  #  {
  #     "status": 0,
  #     "message": "此手机号已注册"
  #  }


  def send_verify_code
    # if params[:captcha].blank? || !simple_captcha_valid?
    #   render :text => 'captcha error'
    #   return
    # end
    if User.where(:mobile  => params[:mobile]).count == 0
      # 生成验证码
      verify_code = 1001 + rand(8980)

      # 发送验证码
      redis = Redis.new
      redis.set params[:mobile], verify_code
      redis.expire params[:mobile], 120

      res = Resque.enqueue(SmsJob, :send_verify_code, params[:mobile], verify_code)
      render 'layouts/api', layout: false
    else
      @status = 0
      @message = '此手机号已注册'
      render 'layouts/api', layout: false
    end
  end


  def require_no_authentication
    sign_out
    if current_user.present?
      @data = current_user
      render 'layouts/api', layout: false
      return
    end

    assert_is_devise_resource!
    return unless is_navigational_format?
    no_input = devise_mapping.no_input_strategies

    authenticated = if no_input.present?
      args = no_input.dup.push scope: resource_name
      warden.authenticate?(*args)
    else
      warden.authenticated?(resource_name)
    end

    if authenticated && resource = warden.user(resource_name)
      flash[:alert] = I18n.t("devise.failure.already_authenticated")
      redirect_to after_sign_in_path_for(resource)
    end
  end
end