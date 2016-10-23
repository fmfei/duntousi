class Bonu < ActiveRecord::Base
  belongs_to :user

  scope :cash, ->{where("category = 'cash'")}
  scope :actual_object, ->{where("category = 'actual_object'")}
  scope :bribery_money, ->{where("category = 'bribery_money'")}
end
