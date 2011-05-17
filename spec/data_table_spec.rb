require "spec_helper"

describe DataTable do

  include DataTable::ClassMethods

  context "on being included" do
    it "should extend ClassMethods" do
      klass = Class.new
      mock(klass).send(:extend, DataTable::ClassMethods)
      mock(klass).send(:extend, DataTable::Mongoid::ClassMethods)
      klass.instance_eval %{include DataTable}
    end
  end

  context "#for_data_table" do

    it "should produce JSON for the datatables plugin to consume" do
      params = {:sSearch => "answer", :iSortCol_0 => "0", :sSortDir_0 => "desc", :iDisplayLength => "10", :sEcho => "1"}
      controller = mock!.params { params }.subject

      fields = %w(foo bar baz)
      search_fields = %w(foo bar)
      date_search_fields = %w(foo)
      block = :block
      
      search_fields_without_dates = %w(bar)

      mock(self).count { 42 }
      objects = mock!.total_entries { 10 }.subject
      mock(self)._find_objects(params, fields, search_fields_without_dates, date_search_fields) { objects }
      mock(self)._yield_and_render_array(controller, objects, block) { :results }

      result = for_data_table(controller, fields, search_fields, date_search_fields, block)
      result.should == {:sEcho => 1, :iTotalRecords => 42, :iTotalDisplayRecords => 10, :aaData => :results}.to_json.html_safe
    end

  end

  context "#_yield_and_render_array" do

    it "should walk through the array and render it, passing in the appropriate local name" do
      block = lambda {|x| mock!.map { [42] }.subject }

      result = _yield_and_render_array Object.new, [:foo], block
      result.should == [[42]]
    end

  end

  context "#_page" do

    context "with a display length of 10" do
      it "should return 1 when start is blank" do
        send(:_page, {:iDisplayStart => "", :iDisplayLength => "10"}).should == 1
      end

      it "should return 1 when start is 0" do
        send(:_page, {:iDisplayStart => "0", :iDisplayLength => "10"}).should == 1
      end

      it "should return 2 when start is 10" do
        send(:_page, {:iDisplayStart => "10", :iDisplayLength => "10"}).should == 2
      end
    end

  end

  context "#_per_page" do

    it "should return 10 given an iDisplayLength of 10" do
      send(:_per_page, {:iDisplayLength => "10"}).should == 10
    end

    it "should return a default of 25 given an invalid iDisplayLength" do
      send(:_per_page, {:iDisplayLength => "foobar"}).should == 25
    end

    it "should return self.count given an iDisplayLength of -1" do
      mock(self).count { :all }
      send(:_per_page, {:iDisplayLength => "-1"}).should == :all
    end

  end

end
