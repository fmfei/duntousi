# encoding: utf-8
class Api::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token
  respond_to :html, :json

  ##
  #
  # 用户登录
  #
  # POST /api/sessions
  #
  # 参数：
  #  user[mobile]
  #  user[password]
  #
  # 返回值
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "id": 2,
  #         "email": "",
  #         "created_at": "2015-07-07T09:57:58.225+08:00",
  #         "updated_at": "2015-11-17T14:10:13.902+08:00",
  #         "encrypted_trade_password": "$2a$10$SXTy6lCIzgoLWCeX2graZOopNEREvPF2G2EjHnsnyf1QLflMKIema",
  #         "auth_mobile": true,
  #         "auth_realname": 1,
  #         "from_user_id": null,
  #         "mobile": "13121223780",
  #         "branch": null,
  #         "register_ip": null,
  #         "source": null,
  #         "channel": null,
  #         "authentication_token": "fwXF_-HpC7rdCvUwnxyw"
  #     }
  #  }
  def create
    resource = User.find_by_mobile(params[:user][:mobile])
    if resource && resource.valid_password?(params[:user][:password])

      sign_in(resource_name, resource)

      @data = resource
      render 'layouts/api', layout: false
    else
      @status = 0
      @message = '手机号或密码错误'
      render 'layouts/api', layout: false
    end

  end



  ##
  #
  # 用户退出
  #
  # GET /api/sessions/logout
  #
  # 返回值
  #
  #  {
  #     "msg": "已经退出"
  #  }
  #
  def logout
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    render json: {msg: '已经退出'}
  end

  def require_no_authentication
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

  private
    def auth_options
      params.require(:user).permit(:mobile,:password)
    end

    def respond_to_on_destroy
      # We actually need to hardcode this as Rails default responder doesn't
      # support returning empty response on GET request
      respond_to do |format|
        format.json {render json: {status: 0, message: "success", data: {res: 'success'}}}
        # format.html { head :no_content }
        format.html { redirect_to after_sign_out_path_for(resource_name) }
      end
    end

end