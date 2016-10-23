class Identification < ActiveRecord::Base
  mount_uploader :file, FileUploader
  belongs_to :user

  CATEGORY = {'抵押物材料' => 'mortgage', '公司证件' => 'ident_company', '其它工作及经营情况资料' => 'ident_others', '借款申请表' => 'ident_apply', '担保借款协议' => 'ident_guarantee', '抵押借款协议' => 'ident_mortgage', '房产资料' => 'house', '身份证' => 'id_card'}
end
