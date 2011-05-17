require "spec_helper"

describe DataTable do

  include DataTable::ActiveRecord::ClassMethods

  context "#_find_objects" do

    it "should find the objects required based on the params" do
      params = {:sSearch => "answer", :iSortCol_0 => "0", :sSortDir_0 => "desc", :iDisplayLength => 10, :sEcho => 1}

      mock(self)._discover_joins(%w(foo bar baz)) { [] }
      mock(self)._where_conditions("answer", %w(foo bar), %w(baz)) { "where clause" }
      mock(self)._order_fields(params, %w(foo bar baz)) { "order" }

      mock(self).where("where clause") { mock!.includes([]) { mock!.order("order") { mock!.paginate({:page => :page, :per_page => :per_page}) { :answer } } } }
      mock(self)._page(params) { :page }
      mock(self)._per_page(params) { :per_page }

      _find_objects(params, %w(foo bar baz), %w(foo bar), %w(baz)).should == :answer
    end

  end

  context "#_where_conditions" do

    it "should return nil if the query is blank" do
      send(:_where_conditions, "", %w(foo bar baz), %(baz)).should == nil
    end

    it "should return an AR array with an entry for each search field" do
      send(:_where_conditions, "query", %w(foo bar), %w(baz)).should == ["UPPER(foo) LIKE ? OR UPPER(bar) LIKE ? OR baz LIKE ?", "%QUERY%", "%QUERY%", "%QUERY%"]
    end

  end

  context "#_discover_joins" do

     it "should return the joins on the fields" do
       _discover_joins(%w(foo.bar foz.ber baz)).should == [:foo, :foz]
     end

  end

  context "#_order_fields" do

    it "should find the field name and pass the sort direction" do
      send(:_order_fields, {:iSortCol_0 => "1", :sSortDir_0 => "asc"}, %w(foo bar baz)).should == "bar ASC"
    end

  end
end
