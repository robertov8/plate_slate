defmodule PlateSlateWeb.Schema.Query.MenuItemsTest do
  use PlateSlateWeb.ConnCase, async: true

  alias PlateSlate.{Menu, Repo}

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
          %{"name" => "Bánh mì"},
          %{"name" => "Chocolate Milkshake"},
          %{"name" => "Croque Monsieur"},
          %{"name" => "French Fries"},
          %{"name" => "Lemonade"},
          %{"name" => "Masala Chai"},
          %{"name" => "Muffuletta"},
          %{"name" => "Papadum"},
          %{"name" => "Pasta Salad"},
          %{"name" => "Reuben"},
          %{"name" => "Soft Drink"},
          %{"name" => "Vada Pav"},
          %{"name" => "Vanilla Milkshake"},
          %{"name" => "Water"}
        ]
      }
    }

    assert json_response(conn, :ok) == expected_response
  end

  test "menuItems field returns menu items filtered by name" do
    query = """
    query($filter: MenuItemFilter!) {
      menuItems(filter: $filter) {
        name
      }
    }
    """

    variables = %{filter: %{"name" => "reu"}}

    response = get(build_conn(), "/graphql", query: query, variables: variables)

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
          "message" =>
            "Unknown argument \"matching\" on field \"menuItems\" of type \"RootQueryType\"."
        }
      ]
    }

    assert json_response(response, 200) == expected_response
  end

  test "menuItems field filters by name when using a variable" do
    query = """
    query($filter: MenuItemFilter) {
      menuItems(filter: $filter) {
        name
      }
    }
    """

    variables = %{filter: %{"name" => "reu"}}

    response = get(build_conn(), "/graphql", query: query, variables: variables)

    expected_response = %{"data" => %{"menuItems" => [%{"name" => "Reuben"}]}}

    assert json_response(response, :ok) == expected_response
  end

  test "menuItems field returns items desceding using literals" do
    query = """
    query($order: SortOrder!) {
      menuItems(order: $order) {
        name
      }
    }
    """

    variables = %{order: "DESC"}

    response = get(build_conn(), "/graphql", query: query, variables: variables)

    assert %{"data" => %{"menuItems" => [%{"name" => "Water"} | _]}} =
             json_response(response, :ok)
  end

  test "menuItems field returns menuItems, filtering with a literal" do
    query = """
    {
      menuItems(filter: {category: "Sandwiches", tag: "Vegetarian"}) {
        name
      }
    }
    """

    expected_response = %{"data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}}

    response = get(build_conn(), "/graphql", query: query)
    assert json_response(response, :ok) == expected_response
  end

  test "menuItems field returns menuItems, filtering with a variable" do
    query = """
    query($filter: MenuItemFilter!) {
      menuItems(filter: $filter) {
        name
      }
    }
    """

    variables = %{filter: %{"category" => "Sandwiches", "tag" => "Vegetarian"}}

    expected_response = %{"data" => %{"menuItems" => [%{"name" => "Vada Pav"}]}}

    response = get(build_conn(), "/graphql", query: query, variables: variables)
    assert json_response(response, :ok) == expected_response
  end

  test "menuItems field by custom scalar" do
    Repo.insert!(%Menu.Item{
      name: "Garlic Fries",
      added_on: ~D[2017-01-20],
      price: 2.50,
      category: Repo.get_by(Menu.Category, name: "Sides")
    })

    query = """
    query($filter: MenuItemFilter!) {
      menuItems(filter: $filter) {
        name
        addedOn
      }
    }
    """

    variables = %{filter: %{"addedBefore" => "2017-01-20"}}

    expected_response = %{
      "data" => %{
        "menuItems" => [
          %{"name" => "Garlic Fries", "addedOn" => "2017-01-20"}
        ]
      }
    }

    response = get(build_conn(), "/graphql", query: query, variables: variables)
    assert json_response(response, :ok) == expected_response
  end

  test "menuItems filtered by custom scalar with error" do
    query = """
    query($filter: MenuItemFilter!) {
      menuItems(filter: $filter) {
        name
        addedOn
      }
    }
    """

    variables = %{filter: %{"addedBefore" => "not-a-date"}}

    expected_response = %{
      "errors" => [
        %{
          "locations" => [%{"column" => 13, "line" => 2}],
          "message" =>
            "Argument \"filter\" has invalid value $filter.\nIn field \"addedBefore\": Expected type \"Date\", found \"not-a-date\"."
        }
      ]
    }

    response = get(build_conn(), "/graphql", query: query, variables: variables)
    assert json_response(response, :ok) == expected_response
  end
end
