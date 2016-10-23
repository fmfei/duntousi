# encoding: utf-8
class RegistrationsController < Devise::RegistrationsController
	before_action :configure_permitted_parameters
	layout 'devise'
	def new
		super
	end

	def create
		redis = Redis.new
		verify_code = redis.get params[:user][:mobile]
		if params[:verify_code] == verify_code || !Utils.production?
			super do |resource|
				resource.roles << Role.find_by_name('投资人')
				resource.from_user_id = cookies[:from_user]
				resource.source = cookies[:source]
				resource.channel = cookies[:channel]
				resource.auth_mobile = true
				resource.save
				if resource.errors.present?
					# if resource.errors[:email] == ["不可用"] || resource.errors[:username] == ['用户名已存在']
					if resource.errors[:mobile] == ["号码已存在"]
						flash[:errors] = '此用户已注册。'
					else
						flash[:errors] = resource.errors
					end
					redirect_to :back
					return
				else
					# return render :action => :confirmable
					sign_in(resource)
					resource.update_attribute(:register_ip, resource.current_sign_in_ip)

					#新手注册赠送2000体验金
					current_user.user_cash.update_attribute(:rookie_amount, 2000)

					redirect_to real_name_account_users_path
					return
				end
			end
		else
			flash[:errors] = '验证码错误或过期，请重新注册。'
			redirect_to :back
		end
	end

	def confirmable

	end

  def validate_captcha
    if simple_captcha_valid?
      render text: 'ok'
    else
      render text: 'error'
    end
  end

	private

	def configure_permitted_parameters
	  devise_parameter_sanitizer.for(:sign_up) { |u| u.permit( :email, :username, :password, :password_confirmation, :mobile) }
	end
end