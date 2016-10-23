# encoding: utf-8

module Account::BaseHelper

  def form_note_account flash_note
    notice = ''
    if flash_note[:errors] && flash_note[:errors].is_a?(String)
      notice += '<div class="alert alert-danger alert-dismissable">'
      notice += '<a class="close" data-dismiss="alert" href="#">×</a>'
      notice += '<i class="icon-remove-sign"></i>&nbsp;'
      notice += flash_note[:errors]
      notice += '</div>'
    elsif flash_note[:errors] && flash_note[:errors].any?
      notice += '<div class="alert alert-danger alert-dismissable">'
      notice += '<a class="close" data-dismiss="alert" href="#">×</a>'
      notice += '<i class="icon-remove-sign"></i>&nbsp;'
      notice += flash_note[:errors].messages.values.join(' ')
      notice += '</div>'
    elsif flash_note[:success]
      notice += '<div class="alert alert-success alert-dismissable">'
      notice += '<a class="close" data-dismiss="alert" href="#">×</a>'
      notice += '<i class="icon-ok-sign"></i>&nbsp;'
      notice += flash_note[:success]
      notice += '</div>'
    elsif flash_note[:info]
      notice += '<div class="alert alert-info alert-dismissable">'
      notice += '<a class="close" data-dismiss="alert" href="#">×</a>'
      notice += '<i class="icon-info-sign"></i>&nbsp;'
      notice += flash_note[:info]
      notice += '</div>'
    elsif flash_note[:warning]
      notice += '<div class="alert alert-warning alert-dismissable">'
      notice += '<a class="close" data-dismiss="alert" href="#">×</a>'
      notice += '<i class="icon-info-sign"></i>&nbsp;'
      notice += flash_note[:warning]
      notice += '</div>'
    end
    flash_note.discard
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

  def li_link_to_account(text, url, active = false, options = {})
    if active
      options[:class].present? ? options[:class] += ' active' : options[:class] = 'active'
    end
    append_to_li = options
    content_tag :li, append_to_li do
      link_to ("<i class='#{options[:i_class].present? ? options[:i_class] : 'icon-caret-right'}'></i><span>#{text}</span>").html_safe, url
    end
  end

  def will_paginate(collection, options = {})
    options = options.merge(:renderer => 'PaginationListLinkRenderer') unless options[:renderer]
    super(collection, options)
  end

  def translate_lucky_status(status)
    if status == "not_win"
      return "未中奖"
    elsif status == 'win'
      return "中奖"
    else
      return "等待开奖"
    end
  end

end
