# encoding: utf-8
class Backend::BaseController < ApplicationController
	include Bootstrap::Breadcrumb
#  include MongodbLogger::Base

  skip_before_filter :site_avaliable
	before_filter :authenticate_user!, :verify_admin
	before_filter :init_breadcrumb, :except => [:create, :update, :destroy]
  before_filter :add_logger

	layout 'backend'

	def init_breadcrumb(options = {})
	  drop_breadcrumb params[:controller] , url_for(:controller => params[:controller])
	  drop_breadcrumb params[:action] unless params[:action] == 'index'
	end

  def add_logger
    Rails.logger.add_metadata(user_id: current_user.id) if Rails.logger.respond_to?(:add_metadata)
    Rails.logger.add_metadata(user_email: current_user.email) if Rails.logger.respond_to?(:add_metadata)
  end

  private
  def verify_admin
    redirect_to root_url unless current_user.roles.is_admin.present?
  end
end
