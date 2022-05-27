defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  setup do
    PlateSlate.Seeds.run()
  end

  test "menuItems field returns menu items" do
    query = """
    {
      menuItems {
        name
      }
    }
    """

    conn = get(build_conn(), "/graphql", query: query)

    expected_response = %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Reuben"},
          %{"name" => "Croque Monsieur"},
          %{"name" => "Muffuletta"},
          %{"name" => "Bánh mì"},
          %{"name" => "Vada Pav"},
          %{"name" => "French Fries"},
          %{"name" => "Papadum"},
          %{"name" => "Pasta Salad"},
          %{"name" => "Water"},
          %{"name" => "Soft Drink"},
          %{"name" => "Lemonade"},
          %{"name" => "Masala Chai"},
          %{"name" => "Vanilla Milkshake"},
          %{"name" => "Chocolate Milkshake"}
        ]
      }
    }

    assert json_response(conn, :ok) == expected_response
  end

  test "menuItems field returns menu items filtered by name" do
    query = """
    {
      menuItems(matching: "reu") {
        name
      }
    }
    """

    response = get(build_conn(), "/graphql", query: query)

    expected_response = %{"data" => %{"menuItems" => [%{"name" => "Reuben"}]}}

    assert json_response(response, :ok) == expected_response
  end

  test "menuItems field returns erros when using a bad value" do
    query = """
    {
      menuItems(matching: 123) {
        name
      }
    }
    """

    response = get(build_conn(), "/graphql", query: query)

    expected_response = %{
      "errors" => [
        %{
          "locations" => [%{"column" => 13, "line" => 2}],
          "message" => "Argument \"matching\" has invalid value 123."
        }
      ]
    }

    assert json_response(response, 200) == expected_response
  end

  test "menuItems field filters by name when using a variable" do
    query = """
    query($term: String) {
      menuItems(matching: $term) {
        name
      }
    }
    """

    variables = %{term: "reu"}

    response = get(build_conn(), "/graphql", query: query, variables: variables)

    expected_response = %{"data" => %{"menuItems" => [%{"name" => "Reuben"}]}}

    assert json_response(response, :ok) == expected_response
  end
end
