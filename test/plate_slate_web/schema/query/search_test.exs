defmodule PlateSlateWeb.Schema.Query.SearchTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  test "search returns a list of menu items and categories" do
    query = """
    query Search($term: String!) {
      search(matching: $term) {
        name
        __typename
      }
    }
    """

    variables = %{term: "e"}

    response = get(build_conn(), "/graphql", query: query, variables: variables)

    assert %{"data" => %{"search" => results}} = json_response(response, :ok)
    assert length(results) > 0
    assert Enum.find(results, &(&1["__typename"] == "MenuItem"))
    assert Enum.find(results, &(&1["__typename"] == "Category"))
  end
end
