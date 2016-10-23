json.orders @user_banks do |order|
  json.id order.id
  json.card_number '************' + order.card_number[-4..-1].to_s
end
