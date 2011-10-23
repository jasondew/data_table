if defined?(Mongoid)
  module Mongoid
    module DataTable
      def self.included base
        base.send :extend, ::DataTable::ClassMethods
        base.send :extend, ::DataTable::Mongoid::ClassMethods
      end
    end
  end
end
