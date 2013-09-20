module DataTable
  module ActiveRecord
    module ClassMethods

      def _find_objects params, fields, search_fields
        self.where(_build_conditions params, search_fields).
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
			
			def _build_conditions params, search_fields, join_operator = "OR"
				search_params = _search_params params
				return if search_params.empty?
				all_conditions = []
				all_parameters = []
				search_params.each do |key,value|
					next if value[:ssearch].blank?
					value[:ssearch].split.each do |term|
						next if (search_fields[value[:mdataprop].to_i]).nil?
						next if (clause = _where_condition(term, search_fields[value[:mdataprop].to_i].dup)).empty?
						all_conditions << [clause.shift]
						all_parameters += [clause]
					end
				end	
				if !params[:ssearch].blank?
					params[:ssearch].split.each do |term|
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
				end
				[all_conditions.map {|conditions| "(" + conditions.join(" #{join_operator} ") + ")" }.join(" AND "), *all_parameters.flatten]
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
            _split_where_condition query, field, options
          elsif options[:date]
            _date_where_condition query, field.first
          else
            _where_conditions(query, field, "AND")
          end
        else
          ["UPPER(#{field}) LIKE ?", "%#{query.upcase}%"]
        end
      end

      def _date_where_condition query, field
        begin
          ["#{field}::date = ?", Date.parse(query)]
        rescue ArgumentError
          ["NULL!= ?", nil]
        end
      end

      def _split_where_condition query, fields, options
        conditions = []
        parameters = []
        split_query = query.split options[:split]
        types = options[:types] || ([:string] * fields.size)

        if split_query.size == fields.size
          fields.zip(split_query).zip(types).each do |((field, query), type)|
            if type == :numeric
              conditions << "#{field} = ?"
              parameters << query.to_i
            else
              conditions << "UPPER(#{field}) LIKE ?"
              parameters << "%#{query.upcase}%"
            end
          end

          ["(" + conditions.join(" AND ") + ")", *parameters]
        else
          []
        end
      end

      def _order_fields params, fields
        direction = params[:ssortdir_0] == "asc" ? "ASC" : "DESC"
        if fields[params[:isortcol_0].to_i].is_a? Array
					%{#{fields[params[:isortcol_0].to_i].first} #{direction}}
				else
					%{#{fields[params[:isortcol_0].to_i]} #{direction}}
				end
      end
			
			def _search_params params
				return if params.empty?
				search_params = ["bsortable","mdataprop","ssearch"]
				search = {}
				params.each do |key,value|
					parts = key.to_s.split('_')
					if parts.length==2
						index = parts[1].to_i
						if search_params.include?(parts[0])
							if search[index].nil?
								search[index] = {}
							end
							search[index].merge!(parts[0].to_sym => value)
						end
					end
				end
				search
			end				
    end
  end
end
