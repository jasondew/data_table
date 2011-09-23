require "spec_helper"

describe DataTable do

  include DataTable::ActiveRecord::ClassMethods

  context "#_find_objects" do

    it "should find the objects required based on the params" do
      params = {:ssearch => "answer", :isortcol_0 => "0", :ssortdir_0 => "desc", :idisplaylength => 10, :secho => 1}

      mock(self)._discover_joins(%w(foo bar baz)) { [] }
      mock(self)._where_conditions("answer", %w(foo bar)) { "where clause" }
      mock(self)._order_fields(params, %w(foo bar baz)) { "order" }

      mock(self).where("where clause") { mock!.includes([]) { mock!.order("order") { mock!.paginate({:page => :page, :per_page => :per_page}) { :answer } } } }
      mock(self)._page(params) { :page }
      mock(self)._per_page(params) { :per_page }

      _find_objects(params, %w(foo bar baz), %w(foo bar)).should == :answer
    end

  end

  context "#_where_conditions" do

    it "should return nil if the query is blank" do
      send(:_where_conditions, "", %w(foo bar baz)).should == nil
    end

    it "should return an AR array with an entry for each search field" do
      send(:_where_conditions, "query", %w(foo bar)).should == ["(UPPER(foo) LIKE ? OR UPPER(bar) LIKE ?)", "%QUERY%", "%QUERY%"]
    end

    context "with multiple terms" do
      it "should return an AR array with conditions for all combinations of terms and fields" do
        send(:_where_conditions, "q1 q2", %w(f1 f2)).should == ["(UPPER(f1) LIKE ? OR UPPER(f2) LIKE ?) AND (UPPER(f1) LIKE ? OR UPPER(f2) LIKE ?)", "%Q1%", "%Q1%", "%Q2%", "%Q2%"]
      end
    end

    context "with a date field" do
      it "should return an AR array using equality and converting to a date" do
        send(:_where_conditions, "2011/09/03", [["f1", {:date => true}]]).should == ["(f1 = ?)", Date.new(2011, 9, 3)]
      end

      it "should return an AR array properly not search date fields with non-dates" do
        send(:_where_conditions, "foo", ["f1", ["f2", {:date => true}]]).should == ["(UPPER(f1) LIKE ?)", "%FOO%"]
      end
    end

    context "with complex conditions" do
      it "should return an AR array with an entry for each search field" do
        send(:_where_conditions, "query", [%w(foo bar)]).should == ["((UPPER(foo) LIKE ? AND UPPER(bar) LIKE ?))", "%QUERY%", "%QUERY%"]
      end

      it "should return an AR array with an entry for each search field with a split query" do
        send(:_where_conditions, "query-two", [['foo', 'bar', {:split => '-'}]]).should == ["((UPPER(foo) LIKE ? AND UPPER(bar) LIKE ?))", "%QUERY%", "%TWO%"]
      end

      it "should return an AR array with an entry for each search field with ands and ors" do
        send(:_where_conditions, "query", ['foz', ['foo', 'bar']]).should == ["(UPPER(foz) LIKE ? OR (UPPER(foo) LIKE ? AND UPPER(bar) LIKE ?))", "%QUERY%", "%QUERY%", "%QUERY%"]
      end

      it "should return an AR array with an entry for each search field with ands and ors with a split query" do
        send(:_where_conditions, "query-two", ['foz', ['foo', 'bar', {:split => '-'}]]).should == ["(UPPER(foz) LIKE ? OR (UPPER(foo) LIKE ? AND UPPER(bar) LIKE ?))", "%QUERY-TWO%", "%QUERY%", "%TWO%"]
      end

      it "should ignore a split query if the query isn't the size of the split fields" do
        send(:_where_conditions, "query", ['foz', ['foo', 'bar', {:split => '-'}]]).should == ["(UPPER(foz) LIKE ?)", "%QUERY%"]
      end

      it "should still work with multiple terms" do
        send(:_where_conditions, "q1 q-2", ['F1', ['P1', 'P2', {:split => '-'}]]).should ==
          ["(UPPER(F1) LIKE ?) AND (UPPER(F1) LIKE ? OR (UPPER(P1) LIKE ? AND UPPER(P2) LIKE ?))", "%Q1%", "%Q-2%", "%Q%", "%2%"]
      end
    end
  end

  context "#_discover_joins" do

    it "should return the joins on the fields" do
      mock(self).new {self}
      stub(self).foo {true}
      stub(self).foz {true}
      stub(self).furs {true}

      joins = _discover_joins(%w(foo.bar foz.ber furs.bib nones.zip baz))
      joins.should include :foo
      joins.should include :foz
      joins.should include :furs
      joins.should_not include :nones
    end

  end

  context "#_order_fields" do

    it "should find the field name and pass the sort direction" do
      send(:_order_fields, {:isortcol_0 => "1", :ssortdir_0 => "asc"}, %w(foo bar baz)).should == "bar ASC"
    end

  end
end
