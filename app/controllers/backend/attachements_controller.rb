# encoding: utf-8
class Backend::AttachementsController < Backend::BaseController
  def index
    @title = "一元夺宝管理"
    #@products = Product.all.order('id desc').paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @title = "新建图片"
    @attachement = Attachement.new
    @product_id = params[:format]
    @product_pic = Product.find(@product_id).attachements.all
  end

  def create_attachement
    product = Product.find(params[:format])
    @attachement = product.attachements.new(attachement_params)
    @attachement.is_main = false
    if @attachement.save
      flash[:success] = "添加成功"
    else
      flash[:errors] = @attachement.errors
    end
    @product_id = params[:format]
    @product_pic = product.attachements.all
    # flash[:errors] = @attachement.errors
    redirect_to new_backend_attachement_path(@product_id)
  end

  def main_pic
    # pic = Attachement.find(params['pic_id'])
    # main_pic = Attachement.main_pic.first
    product = Product.find(params[:product_id])
    pic = product.attachements.find(params[:pic_id])
    main_pic = product.attachements.main_pic.first
    if main_pic.blank?
      pic.is_main = true
      pic.save
    else
      pic.is_main = true
      main_pic.is_main = false
      pic.save
      main_pic.save
    end
    redirect_to new_backend_attachement_path(params['product_id'])
  end

  def show
   
  end

  def destroy
    @pic = Attachement.find(params[:id])
    @pic.destroy
    redirect_to(new_backend_attachement_path(params[:format]))
  end

  def edit_product
    @title = "产品编辑"
  end

  private
    def attachement_params
      params.require(:attachement).permit(:is_main, :pic_name)
    end

end