class Item < ActiveRecord::Base
  belongs_to :product
  has_many :product_orders
  serialize :number_array, Array

  def self.create_for(product_id, total_price)
    self.create(product_id: product_id, already: 0, remain: total_price, number_array: (10000001..(10000000+total_price)).to_a)
  end

  def update_already_remain already, remain, number_array
    self.update_attributes(already: already, remain: remain, number_array: number_array)
  end

  def update_hit_info hit_time, hit_number, number_total, number_rand 
    self.update_attributes(hit_time: hit_time, hit_number: hit_number, number_total: number_total, number_rand: number_rand)
  end
end
