module DataTable
  DataSource = Struct.new(:data, :params, :columns) do
    #ORM-dependent
    def total_count
      @total_count ||= data.count
    end

    #ORM-dependent
    def filtered_count
      filtered.count
    end

    #ORM-dependent
    def current_page
      filtered.order_by([order_column.order_by, order_direction])
              .page(page)
              .per(per_page)
    end

    protected

    #ORM-dependent
    def filtered
      data.where(conditions)
    end

    #ORM-dependent
    def conditions
      return if params.query.to_s !~ /[^[:space:]]/
      query_terms = params.query.split(/\s+/)

      if columns.searchable.size == 1
        search_field = search_field.first

        if query_terms.size == 1
          {search_field => regexp(query_terms.first)}
        else
          {search_field => {"$all" => query_terms.map(&method(:regexp))}}
        end
      else
        {"$and" => query_terms.map {|term| {"$or" => columns.searchable.map {|column| {column.name => regexp(term)} }}}}
      end
    end

    def regexp(string)
      Regexp.new Regexp.escape(string), "i"
    end

    def order_column
      columns[params.sort_column_number]
    end

    def order_direction
      params.sort_direction
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
end
