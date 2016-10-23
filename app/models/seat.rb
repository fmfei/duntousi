class Seat < ActiveRecord::Base

  default_scope { order("id asc") }
  scope :a, ->{where("area = 'A'")}
  scope :b1, ->{where("area = 'B1'")}
  scope :b2, ->{where("area = 'B2'")}
  scope :c, ->{where("area = 'C'")}
  scope :d, ->{where("area = 'D'")}
  scope :e, ->{where("area = 'E'")}
  scope :reserve, ->{where("status = 'reserve'")}
  scope :sold, ->{where("status = 'sold'")}
  scope :idle, ->{where("status = 'idle'")}
end
