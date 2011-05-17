module DataTable
  module Mongoid
    module ClassMethods
      def _find_objects params, fields, search_fields, date_search_fields=nil
        self.where(_where_conditions params[:sSearch], search_fields).
             order_by(_order_by_fields params, fields).
             paginate :page => _page(params), :per_page => _per_page(params)
      end

      def _where_conditions raw_query, search_fields
        return if (query = raw_query.gsub(/\//, "")).blank?

        {"$or" => search_fields.map {|field| {field => /#{query}/i} }}
      end

      def _order_by_fields params, fields
        [fields[params[:iSortCol_0].to_i], params[:sSortDir_0]]
      end
    end
  end
end

