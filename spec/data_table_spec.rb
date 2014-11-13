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
      sSortDir_0: "asc"
    }
  end
  let(:view_context) { ViewContext.new }
  let(:context) { stub params: params_v1, view_context: view_context }
  let(:posts) { stub count: 1000 }
  let(:post1) { stub to_s: "post1", author: "author1" }
  let(:post2) { stub to_s: "post2", author: "author2" }

  it "has a version number" do
    expect(DataTable::VERSION).not_to be nil
  end

  it "renders properly" do
    renderer = DataTable::Renderer.new context: context,
                                       data: posts,
                                       search_fields: %w{name author},
                                       columns: [
                                         {
                                           presenter: ->(post) { link_to post, post },
                                           sort_field: :name
                                         },
                                         :author
                                       ]
    posts.stubs(:where)
         .with({"$and" => [{"$or" => [{"name" => /awesome/i}, {"author" => /awesome/i}]}]})
         .returns(filtered = stub)
    filtered.stubs count: 75
    filtered.stubs(:order_by).with([:name, "asc"]).returns(filtered)
    filtered.stubs(:page).with(1).returns(filtered)
    filtered.stubs(:per).with(10).returns([post1, post2])

    expect(renderer.as_json).to eq({
      draw: 42,
      recordsTotal: 1_000,
      recordsFiltered: 75,
      data: [
        [%Q|<a href="post1">post1</a>|, "author1"],
        [%Q|<a href="post2">post2</a>|, "author2"],
      ]
    })
  end
end
