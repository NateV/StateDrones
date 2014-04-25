

MongoMapper.connection = Mongo::Connection.new('localhost', 27017)
MongoMapper.database = "#statedrones-#{Rails.env}"

if defined?(PhusionPassenger)
  PhusionPassenger.on_even(:starting_worker_process) do |forked|
    MongoMapper.connection.connect if forked
  end
end