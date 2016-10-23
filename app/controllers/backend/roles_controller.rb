# encoding: utf-8
class Backend::RolesController < Backend::BaseController
  def index
    @roles = Role.order('id desc').paginate :page => params[:page], :per_page => 20
    @title = '管理角色'
  end

  def new
   @role = Role.new
   @title = '添加角色'
  end

  def create
    @role = Role.new(roles_params)
    @role.is_admin = params[:role][:is_admin]
    if @role.save
      flash[:success] = '添加成功'
      redirect_to backend_roles_path
    else
      flash[:errors] = @role.errors
      render :new
    end
  end

  def edit
    @role = Role.find(params[:id])
    @permissions = Permission.all
    @title = '修改角色'
  end

  def update
    params[:role][:permission_ids] ||= []
    @role = Role.find(params[:id])
    respond_to do |format|
      if @role.save && @role.update_attributes(roles_params)
        format.html { redirect_to edit_backend_role_url(@role), notice: '更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(backend_roles_path) }
      format.xml  { head :ok }
    end
  end

  def edit_multiple
    @roles = Role.is_admin.where(['name != ?', '超级管理员'])
    @permissions = Permission.order('id')
    @title = '配置权限'
  end

  def update_multiple
    params[:roles] = {} unless params.has_key?(:roles) # if all checkboxes unchecked.
    Role.all.each do |role|
      # this allows for 0 permission checkboxes being checked for a role.
      unless params[:roles].has_key?(role.id.to_s)
        params[:roles][role.id] = { permission_ids: [] }
      end
    end
    @roles = Role.update(params[:roles].keys, params[:roles].values)
    @roles.reject! { |r| r.errors.empty? }
    if @roles.empty?
      redirect_to edit_multiple_backend_roles_path
    else
      render :edit_multiple
    end
  end
  private
    def roles_params
      params.require(:role).permit(:name,:is_admin)
    end

end