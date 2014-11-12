require "rails"
require "active_support/core_ext/object/blank"

begin
  require "active_support/core_ext/object/json"
rescue LoadError
  require "active_support/core_ext/object/to_json" rescue LoadError
end

require "active_support/json/encoding"
require "active_support/core_ext/string/output_safety"
require "active_support/core_ext/string/inflections"

require "data_table/base"
require "data_table/active_record"
require "data_table/mongoid"
require "data_table/rails"
require "mongoid/data_table"
