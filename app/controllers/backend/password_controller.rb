# encoding: utf-8

class Backend::PasswordController < Backend::BaseController

	def index

	end

	def update
		if current_user.update_attributes(pass_params)
			flash[:success] = '密码修改成功'
		else
			flash[:errors] = current_user.errors
		end
		render :index
	end
	private
	 def pass_params
	 	params.require(:user).permit(:password)
	 end
end
