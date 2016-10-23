json.status @status || 1
json.message @message || "success"

if yield.present?
  json.data JSON.parse(yield)
elsif !@data.nil?
  json.data @data
end