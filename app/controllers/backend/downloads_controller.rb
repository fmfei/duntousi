# encoding: utf-8

class Backend::DownloadsController < Backend::BaseController
	include_kindeditor :only => [:new, :edit]
  include_kindeditor :except => [:index, :show, :destroy, :create]

  def index
    @downloads = Download.order("id desc").paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @download = Download.new
  end

  def show
  	@download = Download.find(params[:id])
  end

  def edit
    @download = Download.find(params[:id])
  end

  def create
    @download = Download.new(downloads_params)
    if @download.save
      flash[:success] = '添加成功'
      redirect_to backend_downloads_path
    else
      flash[:errors] = @download.errors
      render :new
    end
  end

  def update
    @download = Download.find(params[:id])

    respond_to do |format|
      if @download.update_attributes(downloads_params)
        format.html { redirect_to backend_downloads_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @download.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @download = Download.find(params[:id])
    @download.destroy

    respond_to do |format|
      format.html { redirect_to backend_downloads_path }
      format.json { head :no_content }
    end
  end
  private
    def downloads_params
      params.require(:download).permit(:name)
    end
end
