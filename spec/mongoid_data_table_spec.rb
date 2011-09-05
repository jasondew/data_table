require "spec_helper"

describe DataTable do

  include DataTable::Mongoid::ClassMethods

  context "#_find_objects" do
    it "should find the objects required based on the params" do
      params = {:sSearch => "answer", :iSortCol_0 => "0", :sSortDir_0 => "desc", :iDisplayLength => 10, :sEcho => 1}

      mock(self)._where_conditions("answer", %w(foo bar)) { "where clause" }
      mock(self)._order_by_fields(params, %w(foo bar baz)) { "order by" }

      mock(self)._page(params) { :page }
      mock(self)._per_page(params) { :per_page }.twice
      mock(self).where("where clause") { mock!.order_by("order by") { mock!.limit(:per_page) { mock!.paginate({:page => :page, :per_page => :per_page}) { :answer } } } }

      _find_objects(params, %w(foo bar baz), %w(foo bar)).should == :answer
    end
  end

  context "#_where_conditions" do

    it "should return nil if the query is blank" do
      send(:_where_conditions, "", %w(foo bar baz)).should == nil
    end

    it "should strip out slashes" do
      send(:_where_conditions, "//", %w(foo bar baz)).should == nil
    end

    it "should return a mongoid $or hash with an entry for each search field" do
      send(:_where_conditions, "q", %w(foo bar)).should == {"$or" => [{"foo" => /q/i}, {"bar" => /q/i}]}
    end

    it "should not use $or if there is only one search field" do
      send(:_where_conditions, "q", %w(f)).should == {"f" => /q/i}
    end

  end

  context "#_order_by_fields" do

    it "should find the field name and pass the sort direction" do
      send(:_order_by_fields,
           {:iSortCol_0 => "1", :sSortDir_0 => "asc"},
           %w(foo bar baz)).should == ["bar", "asc"]
    end

  end
end
