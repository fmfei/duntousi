=begin
require 'mongodb_logger/server' # required
# this secure you web interface by basic auth, but you can skip this, if you no need this
MongodbLogger::Server.use Rack::Auth::Basic do |username, password|
    [username, password] == ['super_admin@admin.com', SystemConfig.mongodb_logger_pass.try(:value)]
end
=end