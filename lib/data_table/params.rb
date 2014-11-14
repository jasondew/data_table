module DataTable
  Params = Struct.new(:context) do
    def draw
      Integer(params[:sEcho] || params[:draw])
    end

    def limit
      Integer(params[:iDisplayLength] || params[:length])
    end

    def offset
      Integer(params[:iDisplayStart] || params[:start])
    end

    def query
      params[:sSearch] || params[:search][:value]
    end

    def sort_column_number
      Integer(params[:iSortCol_0] || params[:order][0][:column])
    end

    def sort_direction
      params[:sSortDir_0] || params[:order][0][:dir] || "asc"
    end

    def view_context
      context.view_context
    end

    private

    def params
      context.params
    end
  end
end
