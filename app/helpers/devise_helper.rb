# coding: utf-8

module DeviseHelper
  def devise_error_messages!
    if flash[:alert]
      messages = flash[:alert]
    elsif !resource.errors.empty?
      #messages = resource.errors.messages.map{|msg| content_tag(:li, t(msg[0])+t(msg[1][0].to_s))}.join
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    else
      return ""
    end

    if messages == "<li>Confirmation token 不合法</li>"
      messages = "<li>验证链接超时，请重新发送验证信息。</li>"
    end

    html = <<-HTML
    <div class="alert alert-danger alert-dismissable">
      <a class="close" data-dismiss="alert" href="#">×</a>
      #{messages}
    </div>
    HTML

    html.html_safe
  end

  def get_mail(email)
    @mail_extension = email.sub(/^([a-z0-9_\.-]+)@/, '')
    @mail_url = 'http://mail.' + @mail_extension
  end
end