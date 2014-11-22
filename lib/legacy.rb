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

require "legacy/base"
require "legacy/active_record"
require "legacy/mongoid"
require "legacy/rails"
require "legacy/mongoid/data_table"
