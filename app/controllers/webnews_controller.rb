# encoding: utf-8

class WebnewsController < ApplicationController
	def index
		# if params[:st].present?
		# 	p = Propaganda.find(params[:st])
		# 	if p.blank?
		# 		render :text => '', :layout => false
		# 		return
		# 	end
		# 	@propagandas = Propaganda.reorder("weight desc").all
		# 	@art_title = p.name
		# 	if @art_title == '网站公告'
		# 		@articles = Article.where(:propaganda_id => p.id).order('id desc').paginate :page => params[:page], :per_page => 20
		# 	else
		# 		@articles = Article.where(:propaganda_id => p.id).order('id').paginate :page => params[:page], :per_page => 20
		# 	end
		# else
		# 	@art_title = "网站公告"
		# 	@articles = Article.paginate :page => params[:page], :per_page => 20
		# end
		if params[:st].present?
			p = Propaganda.find(params[:st])
		else
			p = Propaganda.find_by_name('网站公告')
		end
		@title = p.name
		@articles = Article.where(:propaganda_id => p.id).order('id desc').paginate :page => params[:page], :per_page => 20
		@propagandas = Propaganda.reorder("weight desc").all

		render layout: false
	end

	def show
		@article = Article.find(params[:id])
		if @article
			@propagandas = Propaganda.reorder("weight desc").all
			render layout: false
		else
			render :text => '', :layout => false
		end
		# if @article.propaganda == Propaganda.about_us.current
		# 	render :about_us
		# elsif @article.show_nav
		# 	render :about_us
		# end
	end
end
