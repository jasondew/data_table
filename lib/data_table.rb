require "data_table/version"
require "data_table/params"
require "data_table/data_source"
require "data_table/renderer"
require "data_table/columns"

def DataTable(context:, columns:, data: nil, data_source: nil)
  params = DataTable::Params.new context
  columns = DataTable::Columns.new columns
  data_source ||= DataTable::DataSource.new data, params, columns

  DataTable::Renderer.new params: params,
                          columns: columns,
                          data_source: data_source
end
