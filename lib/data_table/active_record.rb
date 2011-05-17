module DataTable
  module ActiveRecord
    module ClassMethods

      def _find_objects params, fields, search_fields, date_search_fields
        self.where(_where_conditions params[:sSearch], search_fields, date_search_fields).
             includes(_discover_joins fields).
             order(_order_fields params, fields).
             paginate :page => _page(params), :per_page => _per_page(params)
      end

      def _discover_joins fields
        joins = Set.new

        fields.each { |it|
          field = it.split('.')
          if (field.size == 2) then
            joins.add field[0].singularize.to_sym
          end
        }

        joins.collect
      end

      def _where_conditions query, search_fields, date_search_fields
        return if query.blank?
        string_fields = search_fields.map {|field| ["UPPER(#{field}) LIKE ?"] }
        date_search_fields ||= []
        date_fields = date_search_fields.map {|field| ["#{field} LIKE ?"] }
        
        [(string_fields + date_fields).join(" OR "), *(["%#{query.upcase}%"] * (string_fields.size + date_fields.size))]
      end

      def _order_fields params, fields
        direction = params[:sSortDir_0] == "asc" ? "ASC" : "DESC"
        %{#{fields[params[:iSortCol_0].to_i]} #{direction}}
      end
    end
  end
end
