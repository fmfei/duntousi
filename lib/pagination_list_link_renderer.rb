class PaginationListLinkRenderer < ::WillPaginate::ActionView::LinkRenderer

  protected

    def page_number(page)
      unless page == current_page
        tag(:li, link(page, page, :rel => rel_value(page)))
      else
        tag(:li, link(page, 'javascript:avoid(0)'), :class => "current disabled")
      end
    end

    def previous_or_next_page(page, text, classname)
      if page
        tag(:li, link(text, page), :class => classname)
      else
        tag(:li, link(text, 'javascript:avoid(0);'), :class => classname + ' disabled')
      end
    end

    def html_container(html)
      string_attributes = container_attributes.inject('') do |attrs, pair|
        unless pair.last.nil?
          attrs << %( #{pair.first}="#{CGI::escapeHTML(pair.last.to_s)}")
        end
        attrs
      end
      "<div #{string_attributes}><ul #{string_attributes}>#{html}</ul></div>"
    end

    def page_link_or_span(page, span_class, text = nil)
      text ||= page.to_s
      if page && page != current_page
        page_link(page, text, :class => span_class)
      else
        page_span(page, text, :class => span_class)
      end
    end

    def page_link(page, text, attributes = {})
      @template.content_tag(:span, @template.link_to(text, url_for(page)), attributes)
    end

    def page_span(page, text, attributes = {})
      @template.content_tag(:span, text, attributes)
    end
end