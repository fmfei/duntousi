# encoding: utf-8

class Backend::FriendlinksController < Backend::BaseController

  def index
    @title = '友情链接列表'
    @friendlinks = Friendlink.order("id desc").all
  end

  def new
    @friendlink = Friendlink.new
    @title = '添加友情链接'
  end

  def edit
    @friendlink = Friendlink.find(params[:id])
  end

  def create
    @friendlink = Friendlink.new(friendlinks_params)
    if @friendlink.save
      flash[:success] = '添加成功'
      redirect_to backend_friendlinks_path
    else
      flash[:errors] = @friendlink.errors
      render :new
    end
  end

  def update
    @friendlink = Friendlink.find(params[:id])

    respond_to do |format|
      if @friendlink.update_attributes(friendlinks_params)
        format.html { redirect_to backend_friendlinks_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @friendlink.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @friendlink = Friendlink.find(params[:id])
    @friendlink.destroy

    respond_to do |format|
      format.html { redirect_to backend_friendlinks_path }
      format.json { head :no_content }
    end
  end

  def set_weight
  	if params[:weight].present?
  		params[:weight].each_with_index do |f, i|
  			@friendlink = Friendlink.find(f)
  			@friendlink.weight = i
  			@friendlink.save
  		end
  		render :text => 'ok'
  	end
  end
  private
    def friendlinks_params
      params.require(:friendlink).permit(:title,:url,:logo)
    end

end
