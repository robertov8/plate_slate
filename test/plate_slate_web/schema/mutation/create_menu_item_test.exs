defmodule PlateSlateWeb.Schema.Mutation.CreateMenuTest do
  use PlateSlateWeb.ConnCase, async: true

  import Ecto.Query

  alias PlateSlate.{Menu, Repo}

  setup do
    PlateSlate.Seeds.run()

    category_id =
      from(t in Menu.Category, where: t.name == "Sandwiches")
      |> Repo.one!()
      |> Map.fetch!(:id)
      |> to_string()

    {:ok, category_id: category_id}
  end

  @query """
  mutation CreateMenuItem($input: MenuItemInput!) {
    createMenuItem(input: $input) {
      errors { key message }
      menuItem {
        name
        description
        price
      }
    }
  }
  """
  test "createMenuItem field creates an item", %{category_id: category_id} do
    variables = %{
      input: %{
        name: "French Dip",
        description: "Roast beef, caramelized onions, and cheese",
        price: "5.75",
        category_id: category_id
      }
    }

    expected_response = %{
      "data" => %{
        "createMenuItem" => %{
          "errors" => nil,
          "menuItem" => %{
            "description" => "Roast beef, caramelized onions, and cheese",
            "name" => "French Dip",
            "price" => "5.75"
          }
        }
      }
    }

    response = post(build_conn(), "/graphql", query: @query, variables: variables)
    assert json_response(response, :ok) == expected_response
  end

  test "creating a menu item with an existing name fails", %{category_id: category_id} do
    menu_item = %{
      "name" => "Reuben",
      "description" => "Roast beef, caramelized onions, and cheese",
      "price" => "5.75",
      "category_id" => category_id
    }

    expected_response = %{
      "data" => %{
        "createMenuItem" => %{
          "errors" => [%{"key" => "name", "message" => "has already been taken"}],
          "menuItem" => nil
        }
      }
    }

    response = post(build_conn(), "/graphql", query: @query, variables: %{"input" => menu_item})

    assert json_response(response, :ok) == expected_response
  end
end
