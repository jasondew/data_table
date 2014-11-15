require "spec_helper"

describe DataTable do
  class ViewContext
    def link_to(href, title)
      %Q|<a href="#{href}">#{title}</a>|
    end
  end

  let(:params_v1) do
    {
      sEcho: "42",
      iDisplayLength: "10",
      iDisplayStart: "0",
      sSearch: "awesome",
      iSortCol_0: "0",
      sSortDir_0: "desc"
    }
  end

  let(:params_v2) do
    {
      draw: "42",
      length: "10",
      start: "0",
      search: {value: "awesome"},
      order: [{column: "0", dir: "desc"}]
    }
  end

  let(:columns) do
    [
      {
        name: :name,
        presenter: ->(post) { link_to post, post }
      },
      {
        name: :posted,
        searchable: false
      },
      :author
    ]
  end

  let(:posts) { stub count: 1000 }
  let(:post1) { stub to_s: "post1", posted: "15m ago", author: "author1" }
  let(:post2) { stub to_s: "post2", posted: "1d ago", author: "author2" }

  let(:expected_json) do
    {
      draw: 42,
      recordsTotal: 1_000,
      recordsFiltered: 75,
      data: [
        [%Q|<a href="post1">post1</a>|, "15m ago", "author1"],
        [%Q|<a href="post2">post2</a>|, "1d ago", "author2"],
      ]
    }
  end

  it "has a version number" do
    expect(DataTable::VERSION).not_to be nil
  end

  it "renders properly with v1 params" do
    posts.stubs(:where)
         .with({"$and" => [{"$or" => [{name: /awesome/i}, {author: /awesome/i}]}]})
         .returns(filtered = stub)
    filtered.stubs count: 75
    filtered.stubs(:order_by).with([:name, "desc"]).returns(filtered)
    filtered.stubs(:page).with(1).returns(filtered)
    filtered.stubs(:per).with(10).returns([post1, post2])

    expect(
      DataTable(context: context(params_v1),
                data: posts,
                columns: columns).as_json
    ).to eq(expected_json)
  end

  it "renders properly with v2 params" do
    posts.stubs(:where)
         .with({"$and" => [{"$or" => [{name: /awesome/i}, {author: /awesome/i}]}]})
         .returns(filtered = stub)
    filtered.stubs count: 75
    filtered.stubs(:order_by).with([:name, "desc"]).returns(filtered)
    filtered.stubs(:page).with(1).returns(filtered)
    filtered.stubs(:per).with(10).returns([post1, post2])

    expect(
      DataTable(context: context(params_v1),
                data: posts,
                columns: columns).as_json
    ).to eq(expected_json)
  end

  it "accepts search_fields as an override" do
    posts.stubs(:where)
         .with({"author" => /awesome/i})
         .returns(filtered = stub)
    filtered.stubs count: 75
    filtered.stubs(:order_by).with([:name, "desc"]).returns(filtered)
    filtered.stubs(:page).with(1).returns(filtered)
    filtered.stubs(:per).with(10).returns([post1, post2])

    expect(
      DataTable(context: context(params_v1),
                data: posts,
                columns: columns,
                search_fields: %w{author}).as_json
    ).to eq(expected_json)
  end

  it "accepts search_fields with multiple values as an override" do
    posts.stubs(:where)
         .with({"$and" => [{"$or" => [{"name" => /awesome/i}, {"author" => /awesome/i}]}]})
         .returns(filtered = stub)
    filtered.stubs count: 75
    filtered.stubs(:order_by).with([:name, "desc"]).returns(filtered)
    filtered.stubs(:page).with(1).returns(filtered)
    filtered.stubs(:per).with(10).returns([post1, post2])

    expect(
      DataTable(context: context(params_v1),
                data: posts,
                columns: columns,
                search_fields: %w{name author}).as_json
    ).to eq(expected_json)
  end

  private

  def context(params)
    stub params: params, view_context: ViewContext.new
  end
end
