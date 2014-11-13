require "data_table/version"

module DataTable
  Params = Struct.new(:params) do
    def draw
      (params[:sEcho] or params[:draw]).to_i
    end

    def limit
      (params[:iDisplayLength] or params[:length]).to_i
    end

    def offset
      params[:iDisplayStart].to_i
    end

    def query
      params[:sSearch] or params.fetch(:search, {})[:value]
    end

    def sort_column_number
      params[:iSortCol_0].to_i
    end

    def sort_direction
      params[:sSortDir_0] or "asc"
    end
  end

  DataStore = Struct.new(:data, :params, :search_fields, :columns) do
    #ORM-dependent
    def total_count
      @total_count ||= data.count
    end

    #ORM-dependent
    def filtered_count
      filtered.count
    end

    #ORM-dependent
    def ordered_and_paginated
      filtered.order_by(order)
              .page(page)
              .per(per_page)
    end

    private

    #ORM-dependent
    def filtered
      data.where(conditions)
    end

    #ORM-dependent
    def conditions
      return if params.query.to_s !~ /[^[:space:]]/
      query_terms = params.query.split(/\s+/)

      if search_fields.size == 1
        search_field = search_field.first

        if query_terms.size == 1
          {search_field => regexp(query_terms.first)}
        else
          {search_field => {"$all" => query_terms.map(&method(:regexp))}}
        end
      else
        {"$and" => query_terms.map {|term| {"$or" => search_fields.map {|field| {field => regexp(term)} }}}}
      end
    end

    def regexp(string)
      Regexp.new Regexp.escape(string), "i"
    end

    def order
      [sort_column_name, params.sort_direction]
    end

    def sort_column_name
      case (column = columns[params.sort_column_number])
        when Hash   then column[:sort_field]
        when Symbol then column
        else raise "WAT: sort column was #{column.inspect}"
      end
    end

    def page
      return 1 if params.limit.zero? or params.offset.zero?

      params.offset / params.limit + 1
    end

    def per_page
      case params.limit
        when -1 then full_count
        when  0 then 25
        else params.limit
      end
    end
  end

  class Renderer
    attr_reader :context, :data, :search_fields, :columns

    def initialize(context:, data:, search_fields:, columns:)
      @data, @context, @search_fields, @columns = data, context, search_fields, columns
    end

    def as_json(*)
      {
        draw: params.draw,
        recordsTotal: data_store.total_count,
        recordsFiltered: data_store.filtered_count,
        data: formatted_data
      }
    rescue StandardError => exception
      {error: exception.message, backtrace: exception.backtrace}
    end

    private

    def params
      @params ||= Params.new context.params
    end

    def data_store
      @data_store ||= DataStore.new data, params, search_fields, columns
    end

    def view_context
      @view_context ||= context.view_context
    end

    def formatted_data
      @formatted_data ||= begin
        data_store.ordered_and_paginated.map do |datum|
          columns.map do |column|
            formatted_column column, datum
          end
        end
      end
    end

    def formatted_column(column, datum)
      case column
        when Hash           then view_context.instance_exec(datum, &column[:presenter])
        when Symbol, String then datum.send(column)
        else raise "WAT #{column.class}"
      end
    end
  end
end
