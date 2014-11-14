module DataTable
  class Renderer
    attr_reader :params, :columns, :data_source

    def initialize(params:, columns:, data_source:)
      @params, @columns, @data_source = params, columns, data_source
    end

    def as_json(*)
      {
        draw: params.draw,
        recordsTotal: data_source.total_count,
        recordsFiltered: data_source.filtered_count,
        data: formatted_data
      }
    rescue StandardError => exception
      {error: exception.message, backtrace: exception.backtrace}
    end

    private

    def formatted_data
      @formatted_data ||= begin
        data_source.current_page.map do |datum|
          columns.map do |column|
            column.render params.view_context, datum
          end
        end
      end
    end
  end
end
