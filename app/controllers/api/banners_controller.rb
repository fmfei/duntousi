class Api::BannersController < Api::BaseController

  skip_before_action :ajax_requests_required

  ##
  # 首页banner
  #
  # GET /api/banners
  #
  # 返回结果
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "pic": {
  #             "url": "/uploads/banner/pic/2/first.png"
  #         },
  #         "id": 2,
  #         "title": "asdf",
  #         "inner_html": null,
  #         "weight": -1,
  #         "status": true,
  #         "created_at": "2015-10-29T17:10:21.548+08:00",
  #         "updated_at": "2015-11-10T15:27:16.907+08:00",
  #         "url": "http://www.xxxx.com/xxx",
  #         "for_app": true
  #     }
  #  }
  def index
    @banners = Banner.display.for_app
    # render 'layouts/api', layout: false
  end

end