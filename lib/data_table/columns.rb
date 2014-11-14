module DataTable
  class Columns
    extend Forwardable

    def_delegators :columns, :[], :each, :map

    def initialize(definitions)
      self.columns = definitions.map {|definition| Column.new definition }
    end

    def names
      columns.map(&:name)
    end

    def searchable
      columns.select(&:searchable?)
    end

    private

    attr_accessor :columns
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
      if name
        name
      else
        definition[:order_by]
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
      if definition.respond_to?(:to_h) && definition[:presenter]
        view_context.instance_exec datum, &definition[:presenter]
      else
        datum.send name
      end
    end
  end
end
