# encoding: utf-8
class Backend::PermissionsController < Backend::BaseController
  def index
    @permissions = Permission.order('id desc').paginate :page => params[:page], :per_page => 40
    @title = '管理权限'
  end

  def new
   @permission = Permission.new
   @title = '添加权限'
  end

  def create
    @permission = Permission.new(params[:permission])
    if @permission.save
      flash[:success] = '添加成功'
      redirect_to backend_permissions_path
    else
      flash[:errors] = @permission.errors
      render :new
    end
  end

  def edit
    @permission = Permission.find(params[:id])
  end

  def update
    @permission = Permission.find(params[:id])

    respond_to do |format|
      if @permission.update_attributes(params[:permission])
        format.html { redirect_to edit_backend_permission_url(@permission), notice: '更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @permission.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @permission = Permission.find(params[:id])
    @permission.destroy

    respond_to do |format|
      format.html { redirect_to(backend_permissions_path) }
      format.xml  { head :ok }
    end
  end

end