# encoding: utf-8

class SessionsController < Devise::SessionsController
	 skip_before_action :site_avaliable
	 skip_before_action :verify_authenticity_token, :only => [:destroy]
	 layout 'devise'

	def new
		self.resource = resource_class.new(sign_in_params)
    clean_up_passwords(resource)
		if params[:role].present? && params[:role] == 'admin'
			return render 'admin', layout: false
		end
	end

	def create
		if params[:role].present?
			@login_user = User.find_by_login(params[:user][:login])
			if @login_user
				if params[:role] == 'admin' && @login_user.is_admin? == false
					flash[:alert] = "手机号或密码错误"
					redirect_to '/admins'
					return
				elsif params[:role] == 'user' && @login_user.is_admin? == true
					flash[:alert] = "手机号或密码错误"
					redirect_to '/users/sign_in'
					return
				else
					super
				end
			else
				flash[:alert] = "手机号或密码错误"
				if params[:role] == 'admin'
					redirect_to '/admins'
				else
					redirect_to '/users/sign_in'
				end
			end
		end
	end

	def after_sign_in_path_for(resource)
	  if resource.is_admin?
	  	if resource.source.present?
	  		'/backend/lenders/branch'
	  	else
		  	'/backend/home'
	  	end
	  else
	  	'/loans'
	  end
	end

	def after_sign_out_path_for(resource)
	  root_path
	end

end