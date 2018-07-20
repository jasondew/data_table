module DataTable

  def self.included base
    base.send :extend, ClassMethods
    base.send :extend, Mongoid::ClassMethods
  end

  module ClassMethods
    def for_data_table controller, fields, search_fields=nil, explicit_block=nil, &implicit_block
      incoming_params = if controller.params.respond_to?(:permit) then
                          controller.params.permit(:sSearch, :sEcho, :iDisplayStart, :iDisplayLength, :iSortCol_0, :sSortDir_0)
                        else
                          controller.params
                        end
      params = Hash[*incoming_params.to_h.map {|key, value| [key.to_s.downcase.to_sym, value] }.flatten]
      search_fields ||= fields
      block = (explicit_block or implicit_block)

      objects = _find_objects params, fields, search_fields
      matching_count = objects.respond_to?(:total_entries) ? objects.total_entries : _matching_count(params, search_fields)

      {:sEcho                => params[:secho].to_i,
       :iTotalRecords        => self.count,
       :iTotalDisplayRecords => matching_count,
       :aaData               => _yield_and_render_array(controller, objects, block)
      }.to_json.html_safe
    end

    private

    def _yield_and_render_array controller, objects, block
      objects.map do |object|
        block[object].map do |string|
          safe_string = string.to_s.gsub("|", " ")
          controller.instance_eval %{
            log_level, Rails.logger.level = Rails.logger.level, Logger::ERROR
            render_to_string(:inline => %q|#{safe_string}|, :locals => {:#{self.name.underscore} => object}).tap do
              Rails.logger.level = log_level
            end
          }
        end
      end
    end

    def _page params
      return 1 if params[:idisplaystart].blank? or params[:idisplaylength].blank?

      params[:idisplaystart].to_i / params[:idisplaylength].to_i + 1
    end

    def _per_page params
      case (display_length = params[:idisplaylength].to_i)
        when -1 then self.count
        when  0 then 25
        else         display_length
      end
    end
  end

end
