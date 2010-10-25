module DataTable
  class Railtie < Rails::Railtie
    initializer 'data_table.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :extend, DataTable::ClassMethods
        ActiveRecord::Base.send :extend, DataTable::ActiveRecord::ClassMethods
      end
    end
  end
end
