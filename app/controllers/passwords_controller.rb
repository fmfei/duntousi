# encoding: utf-8
class PasswordsController < Devise::PasswordsController
	layout 'devise'

	def new
		super
	end

	def edit
		super
	end

	def create
		self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
    	return render :action => :confirmable
    else
      respond_with(resource)
    end
	end

	def confirmable
	end

	protected
    def after_resetting_password_path_for(resource)
    	flash[:success] = "密码重置成功，请登录"
      after_sign_in_path_for(resource)
    end
end