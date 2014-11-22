module DataTable
  module Mongoid
    module ClassMethods
      def _find_objects params, fields, search_fields
        self.where(_where_conditions params[:ssearch], search_fields).
             order_by(_order_by_fields params, fields).
             page(_page params).
             per(_per_page params)
      end

      def _matching_count params, search_fields
        self.where(_where_conditions params[:ssearch], search_fields).count
      end

      def _where_conditions raw_query, search_fields
        query = _sanitize raw_query
        return if (query = _sanitize raw_query).blank?

        if search_fields.size == 1
          terms = query.split(/\s+/)

          if terms.size == 1
            {search_fields.first => /#{terms.first}/i}
          else
            {search_fields.first => {"$all" => terms.map {|term| /#{term}/i }}}
          end
        else
          terms = query.split(/\s+/)
          terms_and_fields = terms.map do |term|
            {"$or" => search_fields.map {|field| {field => /#{term}/i} }}
          end

          {"$and" => terms_and_fields}
        end
      end

      def _order_by_fields params, fields
        [fields[params[:isortcol_0].to_i], params[:ssortdir_0] || "asc"]
      end

      def _sanitize string
        string.to_s.strip.gsub(/([\^\\\/\.\+\*\?\|\[\]\(\)\{\}\$])/) { "\\#{$1}" }
      end
    end
  end
end
