require "spec_helper"

describe DataTable do

  include DataTable::Mongoid::ClassMethods

  context "#_find_objects" do
    it "should find the objects required based on the params" do
      params = {:ssearch => "answer", :isortcol_0 => "0", :ssortdir_0 => "desc", :idisplaylength => 10, :secho => 1}

      mock(self)._where_conditions("answer", %w(foo bar)) { "where clause" }
      mock(self)._order_by_fields(params, %w(foo bar baz)) { "order by" }

      mock(self)._page(params) { :page }
      mock(self)._per_page(params) { :per_page }
      mock(self).where("where clause") { mock!.order_by("order by") { mock!.page(:page) { mock!.per(:per_page) { :answer } } } }

      _find_objects(params, %w(foo bar baz), %w(foo bar)).should == :answer
    end
  end

  context "#_where_conditions" do

    it "should return nil if the query is blank" do
      send(:_where_conditions, "", %w(foo bar baz)).should == nil
    end

    it "should return a mongoid $or hash with an entry for each search field" do
      send(:_where_conditions, "q", %w(foo bar)).should == {"$or" => [{"foo" => /q/i}, {"bar" => /q/i}]}
    end

    it "should not use $or if there is only one search field" do
      send(:_where_conditions, "q", %w(f)).should == {"f" => /q/i}
    end

    context "given multiple search terms" do
      it "should require a match for each term when there is a single search field" do
        send(:_where_conditions, "q1  q2", %w(f)).should == {"f" => {"$all" => [/q1/i, /q2/i]}}
      end

      it "should require a match for each term when there is a single search field with spaces at the end" do
        send(:_where_conditions, "q1   ", %w(f)).should == {"f" => /q1/i}
      end
    end

  end

  context "#_order_by_fields" do

    it "should find the field name and pass the sort direction" do
      send(:_order_by_fields, {:isortcol_0 => "1", :ssortdir_0 => "asc"}, %w(foo bar baz)).should == ["bar", "asc"]
    end

    it "should use defaults if none are given" do
      send(:_order_by_fields, {}, %w(foo bar baz)).should == ["foo", "asc"]
    end

  end

  context "#_sanitize" do

    it "should work for nil" do
      send(:_sanitize, nil).should == ""
    end

    it "should escape characters for the regex" do
      send(:_sanitize, "  ^\\/.+*?|[](){}$  ").should == "\\^\\\\\\/\\.\\+\\*\\?\\|\\[\\]\\(\\)\\{\\}\\$"
    end

  end

end
