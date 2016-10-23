# encoding: utf-8
# 复制于 https://github.com/xdite/bootstrap-rails
module Bootstrap
  module Breadcrumb
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.send :helper, Helpers
      receiver.send :before_filter, :set_breadcrumbs
    end

    module ClassMethods

    end

    module InstanceMethods
      protected

      def set_breadcrumbs
        @breadcrumbs = ["当前位置：<a href='#{backend_home_index_path}'>首页</a>".html_safe]
      end

      def drop_breadcrumb(title=nil, url=nil)
        if title == 'backend/home'
          title = nil
          return
        end
        title ||= t(@page_title)
        url ||= url_for
        if title
          begin
            if url
              @breadcrumbs.push("<a href=\"#{url}\">#{t(title)}</a>".html_safe)
            else
              @breadcrumbs.push("<h1>#{t(title)}</h1>".html_safe)
            end
            
          rescue Exception => e
            
          end
        end
      end

      def drop_page_title(title)
        @page_title = title
        return @page_title
      end

      def no_breadcrumbs
        @breadcrumbs = []
      end
    end

    module Helpers

      def render_breadcrumb
        return "" if @breadcrumbs.size <= 0
        prefix = "".html_safe
        crumb = "".html_safe

        @breadcrumbs.each_with_index do |c, i|
          breadcrumb_class = []
          breadcrumb_class << "first" if i == 0
          breadcrumb_class << "last active" if i == (@breadcrumbs.length - 1)

          if i == (@breadcrumbs.length - 1)
            breadcrumb_content = c
          else
            breadcrumb_content = c + content_tag(:span, "/", :class => "divider")
          end

          crumb += content_tag(:li, breadcrumb_content ,:class => breadcrumb_class )
        end
        return prefix + content_tag(:ul, crumb, :class => "breadcrumb menu clearfix")
      end
    end
  end
end
