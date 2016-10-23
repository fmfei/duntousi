# encoding: utf-8
class Backend::IdentificationsController < Backend::BaseController
	def index
		@user = User.find(params[:user_id])
		@identifications = @user.identifications
		@title = "#{@user.name}的资料列表"
	end

	def new
		@user = User.find(params[:user_id])
		@identification = @user.identifications.new
		@title = '添加资料'
	end

	def create
		@user = User.find(params[:user_id])
    @identification = @user.identifications.new(identifications_params)
    if @identification.save
      flash[:success] = '添加成功'
      redirect_to backend_user_identifications_path(params[:user_id])
    else
      flash[:errors] = @identification.errors
      render :new
    end
	end

	def edit
		@user = User.find(params[:user_id])
		@identification = @user.identifications.find(params[:id])
	end

	def update
		@user = User.find(params[:user_id])
		@identification = @user.identifications.find(params[:id])
  	if @identification.update_attributes(identifications_params)
			flash[:success] = '修改成功'
			redirect_to :action => :index
		else
			flash[:errors] = @identification.errors
			render :edit
		end
	end

	def destroy
		@user = User.find(params[:user_id])
		@identification = @user.identifications.find(params[:id])
    @identification.destroy

    respond_to do |format|
    	flash[:success] = '删除成功'
      format.html { redirect_to(backend_user_identifications_path(params[:user_id])) }
      format.xml  { head :ok }
    end
	end
	private
	  def identifications_params
	  	params.require(:identification).permit(:category, :desc, :file)
	  end
end
