module DataTable
  class Columns
    extend Forwardable

    def_delegators :columns, :[], :each, :map

    def initialize(definitions, search_fields=nil)
      self.columns = definitions.map {|definition| Column.new definition }
      self.search_fields = search_fields.map(&:to_s) if search_fields
    end

    def names
      columns.map(&:name)
    end

    def searchable
      if search_fields
        search_fields
      else
        columns.select(&:searchable?).map(&:name)
      end
    end

    private

    attr_accessor :columns, :search_fields
  end

  Column = Struct.new(:definition) do
    def name
      if definition.respond_to?(:to_h)
        definition[:name]
      else
        definition
      end
    end

    def order_by
      if definition.respond_to?(:to_h) && definition[:order_by]
        definition[:order_by]
      else
        name
      end
    end

    def ordering
      definition[:ordering]
    end

    def searchable?
      if definition.respond_to?(:to_h)
        definition[:searchable] != false
      else
        true
      end
    end

    def render(view_context, datum)
      if definition.respond_to?(:to_h)
        if (presenter = definition[:presenter])
          view_context.instance_exec datum, &definition[:presenter]
        else
          datum.send name
        end
      else
        datum.send definition
      end
    end
  end
end
