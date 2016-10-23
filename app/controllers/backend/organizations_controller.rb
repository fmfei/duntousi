# encoding: utf-8
class Backend::OrganizationsController < Backend::BaseController
  before_filter :find_org, :only=>[:edit, :update , :destroy]

  def index
    @title = '机构管理'
    @search = Organization.search(params[:q])
    @orgs = @search.result.order(:id).paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @title = '机构新建'
    @org = Organization.new
  end

  def create
    @org = Organization.new(organizations_params)
    if @org.save
      flash[:success] = '添加成功'
      redirect_to action: :index
    else
      flash[:errors] = @org.errors
      render :new
    end
  end

  def edit
    @title = '机构编辑'
  end

  def update
    if @org.update_attributes(organizations_params)
      flash[:success] = '修改成功'
      redirect_to action: :index
    else
      flash[:errors] = @org.errors
      render :edit
    end
  end

  def destroy
    if @org.destroy
      flash[:success] = '删除成功'
      redirect_to action: :index
    else
      flash[errors] = '删除失败'
      redirect_to action: :index
    end
  end

  private
  def find_org
    @org = Organization.find(params[:id])
  end
  def organizations_params
    params.require(:organization).permit(:name,:code)
  end
end
