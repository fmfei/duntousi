# encoding: utf-8

class DownloadsController < ApplicationController

	def index
		@downloads = Download.order('id desc').paginate :page => params[:page], :per_page => 20
	end

	def show
		@download = Download.find(params[:id])
	end

end
