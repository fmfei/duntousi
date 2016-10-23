json.array!(@items) do |item|
  json.extract! item, :id, :product_id, :already, :remain, :hit_time, :hit_number, :number_total, :number_rand
  json.url item_url(item, format: :json)
end
