# encoding: utf-8
class ConfirmationsController < Devise::ConfirmationsController
	layout 'devise'
	def new
		super
	end

	def create
		@user = User.find_by_email(params[:user][:email])
		if @user.confirmed_at.nil?
			super do |resource|
				return render :action => :confirmable
			end
		else
			flash[:alert] = "该邮箱已激活"
			redirect_to '/users/confirmation/new'
			return
		end
	end

	def confirmable
	end

	protected

    def after_confirmation_path_for(resource_name, resource)
    	
    	if SystemConfig.prize_register_status.value == 'on' && SystemConfig.prize_register_amount.value.to_f > 0
    		Resque.enqueue(PromotionJob, :prize_register, resource.id)
    	end

      if signed_in?(resource_name)
      	flash[:success] = "激活成功，请登录"
        signed_in_root_path(resource)
      else
      	flash[:success] = "激活成功"
        new_session_path(resource_name)
      end

    end

end