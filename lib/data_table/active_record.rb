module DataTable
  module ActiveRecord
    module ClassMethods
      def _find_objects params, fields, search_fields
        self.where(_where_conditions params[:sSearch], search_fields).
             order(_order_fields params, fields).
             paginate :page => _page(params), :per_page => _per_page(params)
      end

      def _where_conditions query, search_fields
        return if query.blank?

        [search_fields.map {|field| ["UPPER(#{field}) LIKE ?"] }.join(" OR "), *(["%#{query.upcase}%"] * search_fields.size)]
      end

      def _order_fields params, fields
        direction = params[:sSortDir_0] == "asc" ? "ASC" : "DESC"
        %{#{fields[params[:iSortCol_0].to_i]} #{direction}}
      end
    end
  end
end
