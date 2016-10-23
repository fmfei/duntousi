# encoding: utf-8

module Backend::BaseHelper

  def form_note flash_note
  	notice = ''
  	if flash_note[:errors] && flash_note[:errors].is_a?(String)
      notice += '<div class="alert alert-danger alert-dismissable">'
      notice += '<a class="close" data-dismiss="alert" href="#">×</a>'
      notice += '<i class="icon-remove-sign"></i>&nbsp;'
      notice += flash_note[:errors]
      notice += '</div>'
    elsif flash_note[:errors] && flash_note[:errors].any?
  		notice += '<div class="alert alert-error">'
			notice += '<button type="button" class="close" data-dismiss="alert">x</button>'
			flash_note[:errors].full_messages.each do |msg|
				notice += msg
			end
			notice += '</div>'
  	elsif flash_note[:success]
  		notice += '<div class="alert alert-success">'
			notice += '<button type="button" class="close" data-dismiss="alert">x</button>'
			notice += flash_note[:success]
			notice += '</div>'
  	end
  	return notice.html_safe
  end

  def link_to_edit path
    link_to '<i class="icon-pencil"></i>'.html_safe, path
  end

  def link_to_delete path
    icon_html = '<a href="'
    icon_html += path
    icon_html += '" data-method="delete" data-confirm="确定删除？"><i class="icon-remove"></i></a>'
    return icon_html.html_safe
  end

  def link_to_show path
    link_to '<i class="icon-eye-open"></i>'.html_safe, path
  end

  def li_link_to(text, url, active = false, options = {})
    if can? :manage, url
      if active
        options[:class].present? ? options[:class] += ' active' : options[:class] = 'active'
      end
      append_to_li = options
      content_tag :li, append_to_li do
        link_to text, url
      end
    end
  end

  def will_paginate(collection, options = {})
    options = options.merge(:renderer => 'PaginationListLinkRenderer') unless options[:renderer]
    super(collection, options)
  end

  def btn_toolbar
    btn_html = '<div class="btn-toolbar">'
    unless action_name == 'index'
      btn_html += link_to '返回', :back, class: 'btn back_btn'
    end
    btn_html += '</div>'
    btn_html.html_safe
  end

  # type: add 添加
  # options = {name, path, type}
  def btn_toolbar_adds(options = {})
    new_btn = ''
    options.map do |b|
      if b[:type] == 'add'
        new_btn += '<a class="btn btn-primary" href="'+ b[:path] +'"><i class="icon-plus"></i> '+ b[:name] +'</a>'
      elsif b[:type] == 'delete'
        new_btn += '<a class="btn btn-primary" href="'+ b[:path] +'" data-method="delete" data-confirm="确认删除?"><i class="icon-remove"></i> '+ b[:name] +'</a>'
      else
        new_btn += '<a class="btn" href="'+ b[:path] +'">'+ b[:name] +'</a>'       
      end
    end
    js_content = "$(function (){$('.btn-toolbar').append('#{new_btn}')})"
    javascript_tag{js_content.html_safe}
  end

end








