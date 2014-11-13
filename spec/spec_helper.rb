$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "data_table"
require "mocha"

RSpec.configure do |config|
  config.mock_framework = :mocha
end
