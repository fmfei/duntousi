# encoding: utf-8

class User::RegistrationsController < Devise::RegistrationsController


	private

	def configure_permitted_parameters
	  devise_parameter_sanitizer.for(:sign_up) { |u| u.permit({ roles: [] }, :email, :username, :password, :password_confirmation) }
	end
end
