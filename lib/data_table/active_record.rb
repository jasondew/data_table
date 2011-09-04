module DataTable
  module ActiveRecord
    module ClassMethods

      def _find_objects params, fields, search_fields
        self.where(_where_conditions params[:sSearch], search_fields).
             includes(_discover_joins fields).
             order(_order_fields params, fields).
             paginate :page => _page(params), :per_page => _per_page(params)
      end

      def _discover_joins fields
        joins = Set.new
        object = self.new

        fields.each { |it|
          field = it.split('.')

          if (field.size == 2) then
            if object.respond_to?(field[0].to_sym)
              joins.add field[0].to_sym
            elsif object.respond_to?(field[0].singularize.to_sym)
              joins.add field[0].singularize.to_sym
            end
          end
        }

        joins.to_a
      end

      def _where_conditions query, search_fields, join_operator = "OR"
        return if query.blank?

        all_conditions = []
        all_parameters = []

        query.split.each do |term|
          conditions = []
          parameters = []

          search_fields.each do |field|
            next if (clause = _where_condition(term, field.dup)).empty?
            conditions << clause.shift
            parameters += clause
          end

          all_conditions << conditions
          all_parameters << parameters
        end

        [all_conditions.map {|conditions| "(" + conditions.join(" #{join_operator} ") + ")" }.join(" AND "), *all_parameters.flatten]
      end

      def _where_condition query, field
        return [] if query.blank?

        if field.is_a? Array
          options = field.extract_options!

          if options[:split]
            conditions = []
            parameters = []
            split_query = query.split(options[:split])

            if split_query.size == field.size
              field.map do |f|
                conditions << "UPPER(#{f}) LIKE ?"
                parameters << "%#{split_query.shift.upcase}%"
              end
              ["(" + conditions.join(" AND ") + ")", *parameters]
            else
              []
            end
          else
            _where_conditions(query, field, "AND")
          end
        else
          ["UPPER(#{field}) LIKE ?", "%#{query.upcase}%"]
        end
      end

      def _order_fields params, fields
        direction = params[:sSortDir_0] == "asc" ? "ASC" : "DESC"
        %{#{fields[params[:iSortCol_0].to_i]} #{direction}}
      end
    end
  end
end
