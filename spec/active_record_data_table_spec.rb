require "spec_helper"

describe DataTable do

  include DataTable::ActiveRecord::ClassMethods

  context "#_find_objects" do

    it "should find the objects required based on the params" do
      params = {:sSearch => "answer", :iSortCol_0 => "0", :sSortDir_0 => "desc", :iDisplayLength => 10, :sEcho => 1}

      mock(self)._where_conditions("answer", %w(foo bar)) { "where clause" }
      mock(self)._order_fields(params, %w(foo bar baz)) { "order" }

      mock(self).where("where clause") { mock!.order("order") { mock!.paginate({:page => :page, :per_page => 10}) { :answer } } }
      mock(self)._page(params) { :page }

      _find_objects(params, %w(foo bar baz), %w(foo bar)).should == :answer
    end

  end

  context "#_where_conditions" do

    it "should return nil if the query is blank" do
      mock(self).sanitize(:query) { "" }
      send(:_where_conditions, :query, %w(foo bar baz)).should == nil
    end

    it "should return an AR array with an entry for each search field" do
      mock(self).sanitize(:query) { "q" }
      send(:_where_conditions, :query, %w(foo bar)).should == ["foo LIKE ? OR bar LIKE ?", "%q%", "%q%"]
    end

  end

  context "#_order_fields" do

    it "should find the field name and pass the sort direction" do
      send(:_order_fields, {:iSortCol_0 => "1", :sSortDir_0 => "asc"}, %w(foo bar baz)).should == "bar ASC"
    end

  end
end
