require "data_table/version"
require "data_table/params"
require "data_table/data_source"
require "data_table/renderer"
require "data_table/columns"
require "data_table/rails_engine"
require "legacy"

def DataTable context:,
              columns:,
              data: nil,
              search_fields: nil,
              data_source_builder: ->(params, columns) {
                DataTable::DataSource.new data, params, columns
              }
  params = DataTable::Params.new context
  columns = DataTable::Columns.new columns, search_fields
  data_source = data_source_builder.call(params, columns)

  DataTable::Renderer.new params: params,
                          columns: columns,
                          data_source: data_source
end
