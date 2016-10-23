# encoding: utf-8

class Backend::PropagandasController < Backend::BaseController
  def index
    @title = '网站栏目列表'
    @propagandas = Propaganda.level_one.reorder("weight desc").all
  end

  def new
    @propaganda = Propaganda.new
    @title = '添加网站栏目'
  end

  def edit
    @propaganda = Propaganda.find(params[:id])
  end

  def create
    @propaganda = Propaganda.new(propaganda_params)
    if @propaganda.save
      flash[:success] = '添加成功'
      redirect_to backend_propagandas_path
    else
      flash[:errors] = @propaganda.errors
      render :new
    end
  end

  def update
    @propaganda = Propaganda.find(params[:id])

    respond_to do |format|
      if @propaganda.update_attributes(propaganda_params)
        format.html { redirect_to backend_propagandas_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @propaganda.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @propaganda = Propaganda.find(params[:id])
    @propaganda.destroy

    respond_to do |format|
      format.html { redirect_to backend_propagandas_path }
      format.json { head :no_content }
    end
  end
  private
    def propaganda_params
      params.require(:propaganda).permit(:parent_id,:name, :weight)
    end

end
