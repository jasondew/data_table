require "data_table/version"

module DataTable
  class Renderer
    attr_reader :context, :data, :search_fields, :columns

    def initialize(context:, data:, search_fields:, columns:)
      @data, @context, @search_fields, @columns = data, context, search_fields, columns
    end

    def as_json(*)
      {
        draw: draw,
        recordsTotal: full_count,
        recordsFiltered: filtered_data.count,
        data: formatted_data
      }
    rescue StandardError => exception
      {error: exception.message}
    end

    private

    def params
      context.params
    end

    def view_context
      context.view_context
    end

    def draw
      (params[:sEcho] or params[:draw].presence).to_i
    end

    def limit
      (params[:iDisplayLength] or params[:length].presence).to_i
    end

    def offset
      (params[:iDisplayStart].presence).to_i
    end

    def query
      params[:sSearch].presence or params.fetch(:search, {})[:value]
    end

    def sort_column_number
      params[:isortcol_0].to_i
    end

    def sort_direction
      params[:ssortdir_0].presence or "asc"
    end

    def query_terms
      @query_terms ||= query.split(/\s+/)
    end

    #ORM-dependent
    def conditions
      return if query.blank?

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
      [sort_column_name, sort_direction]
    end

    def sort_column_name
      case (column = columns[sort_column_number])
        when Hash   then column[:sort_field]
        when Symbol then column
        else raise "WAT: sort column was #{column.inspect}"
      end
    end

    def page
      return 1 if limit.zero? or offset.zero?

      offset / limit + 1
    end

    def per_page
      case limit
        when -1 then full_count
        when  0 then 25
        else limit
      end
    end

    #ORM-dependent
    def full_count
      @full_count ||= data.count
    end

    #ORM-dependent
    def filtered_data
      data.where(conditions)
    end

    #ORM-dependent
    def final_data
      filtered_data.order_by(order).page(page).per(per_page)
    end

    def formatted_data
      @formatted_data ||= begin
        final_data.map do |datum|
          columns.map do |column|
            column_data(column, datum)
          end
        end
      end
    end

    def column_data(column, datum)
      case column
        when Hash           then view_context.instance_exec(datum, &column[:presenter])
        when Symbol, String then datum.send(column)
        else raise "WAT #{column.class}"
      end
    end
  end
end
