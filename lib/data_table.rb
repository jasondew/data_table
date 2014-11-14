require "data_table/version"
require "data_table/params"
require "data_table/data_store"
require "data_table/renderer"
require "data_table/columns"

def DataTable(context:, columns:, data: nil, data_store: nil)
  params = DataTable::Params.new context
  columns = DataTable::Columns.new columns
  data_store ||= DataTable::DataStore.new data, params, columns

  DataTable::Renderer.new params: params,
                          columns: columns,
                          data_store: data_store
end
