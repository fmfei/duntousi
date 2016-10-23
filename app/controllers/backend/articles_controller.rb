# encoding: utf-8

class Backend::ArticlesController < Backend::BaseController
  include_kindeditor :only => [:new, :edit]
  include_kindeditor :except => [:index, :show, :destroy, :create]

	def index
		@title = '文章列表'
    @articles = Article.order("created_at desc").paginate(:page => params[:page], :per_page => 20)
	end

	def new
		@title = '添加文章'
		@article = Article.new

	end

	def create
		@article = Article.new(articles_params)
    if @article.save
      flash[:success] = '添加成功'
      redirect_to backend_articles_path
    else
      flash[:errors] = @article.errors
      render :new
    end
	end

	def edit
		@article = Article.find(params[:id])
	end

	def update
		@article = Article.find(params[:id])

    respond_to do |format|
      if @article.update_attributes(articles_params)
        format.html { redirect_to backend_articles_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
	end

	def show
		@article = Article.find(params[:id])
	end

	def destroy
    @article = Article.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to backend_articles_path }
      format.json { head :no_content }
    end
  end
  private
    def articles_params
      params.require(:article).permit(:user_id,:title,:propaganda_id,:is_top,:show_nav,:content)
    end

end
