# encoding: utf-8

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # acts_as_token_authentication_handler_for(User, fallback_to_devise: false) if lambda { |controller| controller.request.format.json? }

  include SimpleCaptcha::ControllerHelpers

  # layout "frontend"

  # before_action :system_config
  # before_action :site_avaliable
  # before_action :store_location
  # before_action :set_from_user_id


  def set_from_user_id
    cookies[:from_user] = params[:yaoqingid] if params[:yaoqingid].present?
  end

  def permission
    [self.controller_path, self.controller_path]
  end

  def after_sign_in_path_for(resource)
  	current_user.is_admin? ? backend_home_index_path : home_index_path
	end

	def after_sign_out_path_for(resource)
		current_user.is_admin? ? admins_path : home_index_path
	end

  def system_config
    @title = SystemConfig.find_by_key("title").value
    @keywords = SystemConfig.find_by_key("keywords").value
    @description = SystemConfig.find_by_key("description").value
  end

  def site_avaliable
    unless FrontConfig.get_config['config']['site_avaliable']
      render "/home/maintenance.html", :layout=>false
    end
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    return unless request.get?
    if (request.path != "/users/sign_in" &&
        request.path != "/users/sign_up" &&
        request.path != "/users/password/new" &&
        request.path != "/users/sign_out" &&
        !request.fullpath.match("/users") &&
        !request.fullpath.match("/admins") &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.fullpath
    elsif request.fullpath.match("/admins")
      session[:previous_url] = backend_home_index_path
    end
  end

  def after_sign_in_path_for(resource)
    # session[:previous_url] || root_path
    '/loans'
  end
end
