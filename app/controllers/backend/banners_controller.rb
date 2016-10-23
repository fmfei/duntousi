#encoding:utf-8
class Backend::BannersController < Backend::BaseController
  include_kindeditor :only => [:new, :edit]

  def index
    @title = '首页轮播图片'
    @banners = Banner.order("created_at desc").all
  end

  def new
    @title = '添加轮播图片'
    @banner = Banner.new
  end

  def create
    @banner = Banner.new(banners_params)
    if @banner.save
      flash[:success] = '添加成功'
      redirect_to backend_banners_path
    else
      flash[:errors] = @banner.errors
      render :new
    end
  end

  def edit
    @banner = Banner.find(params[:id])
  end

  def update
    @banner = Banner.find(params[:id])

    respond_to do |format|
      if @banner.update_attributes(banners_params)
        format.html { redirect_to backend_banners_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @banner.errors, status: :unprocessable_entity }
      end
    end
  end


  def show
    @title = "轮播图片预览"
    @banner = Banner.find(params[:id])
  end

  def destroy
    @banner = Banner.find(params[:id])
    @banner.destroy

    respond_to do |format|
      format.html { redirect_to backend_banners_path }
      format.json { head :no_content }
    end
  end

  def set_weight
    if params[:weight].present?
      params[:weight].each_with_index do |f, i|
        @banner = Banner.find(f)
        @banner.weight = i
        @banner.save
      end
      render :text => 'ok'
    end
  end
  private
    def banners_params
      params.require(:banner).permit(:title,:pic, :status,:inner_html, :url, :for_app)
    end
end
