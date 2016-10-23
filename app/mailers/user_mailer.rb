# encoding: utf-8
class UserMailer < Devise::Mailer
  default :from => %q("yataitouzi"<info@yataitouzi.com>)
	helper :application
	include Devise::Controllers::UrlHelpers

	def reset_password_instructions(record, token, opts={})
		headers["template_path"] = "mailer/reset_password_instructions"
  	super
	end

	def confirmation(user)
    @user = user

    mail(to: @user.unconfirmed_email, subject: '亚太投资激活邮件')
  end

  def send_lender(user)
    @user = user

    mail(to: @user.email, subject: '亚太投资邮件')
  end
end