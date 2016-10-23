#coding: utf-8
class UserInfo < ActiveRecord::Base

  # attr_accessible :id, :id_card, :name, :user, :user_id, :marriage_type_id, :child, :education_type_id, :degree_type_id, :province, :city, :area, :detailed_address, :postcode, :phone, :mobile, :company_name, :company_type, :company_industry, :company_job, :company_title, :company_worktime1, :company_worktime2, :company_phone, :company_address, :company_weburl, :company_reamrk, :income, :social_security_id, :housing, :car, :house_address, :house_area, :house_year, :house_status, :house_holder1, :house_holder2, :house_right1, :house_right2, :house_loanyear, :house_loanprice, :house_balance, :house_bank, :mate_name, :mate_id_card, :mate_salary, :mate_phone, :mate_mobile, :mate_company_name, :mate_job, :mate_address, :qq, :avatar, :idcard_pic, :sms_verify_code
  belongs_to :user
  belongs_to :marriage, class_name: "Dict::MarriageType", foreign_key: "marriage_type_id"
  belongs_to :education, class_name: "Dict::EducationType", foreign_key: "education_type_id"
  belongs_to :degree, class_name: "Dict::DegreeType", foreign_key: "degree_type_id"
  belongs_to :gender_type, class_name: "Dict::GenderType", foreign_key: "gender_id"
  mount_uploader :avatar, AvatarUploader
  mount_uploader :idcard_pic, IdcardPicUploader

  validate :validate_pic
  # validates :mobile, :presence => true, :uniqueness => {:message=>"手机号码错误"}, :format => {:with=>/.{11}/i, :message=>"请输入正确的手机号码"}
  validates :id_card, :presence => true, :format => {:with=>/.{18}/i, :message=>"请输入正确的身份证号码"}

  def address
    begin
      ChinaCity.get(self.province).to_s+ChinaCity.get(self.city).to_s+ChinaCity.get(self.area).to_s
    rescue Exception => e
      ''
    end
  end

  def gender
    self.gender_type.present? ? self.gender_type.name : "未知"
  end

  def generate_sms_verify_code mobile
    verify_code = 1001 + rand(8980)
    self.update_attribute(:sms_verify_code, verify_code)
    self.user.update_attribute(:mobile, mobile)
    verify_code
  end

  private
  def validate_pic
    if idcard_pic.size > 1024 * 1024 * 4 || avatar.size > 1024 * 1024 * 4
      errors[:idcard_pic] << "图片超过4M，请限制在4M内"
    end
  end
end
