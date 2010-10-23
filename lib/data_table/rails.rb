ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send :extend, DataTable::ClassMethods
  ActiveRecord::Base.send :extend, DataTable::ActiveRecord::ClassMethods
end
