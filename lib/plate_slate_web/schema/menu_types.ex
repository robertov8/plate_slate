defmodule PlateSlateWeb.Schema.MenuTypes do
  use Absinthe.Schema.Notation

  alias PlateSlateWeb.Resolvers

  interface :search_result do
    field :name, :string

    resolve_type fn
      %PlateSlate.Menu.Item{}, _ -> :menu_item
      %PlateSlate.Menu.Category{}, _ -> :category
      _, _ -> nil
    end
  end

  # union :search_result do
  #   types [:menu_item, :category]

  #   resolve_type fn
  #     %PlateSlate.Menu.Item{}, _ -> :menu_item
  #     %PlateSlate.Menu.Category{}, _ -> :category
  #     _, _ -> nil
  #   end
  # end

  object :menu_queries do
    field :menu_items, list_of(:menu_item) do
      arg :filter, :menu_item_filter
      arg :order, type: :sort_order, default_value: :asc

      resolve &Resolvers.Menu.menu_items/3
    end
  end

  object :category do
    interfaces [:search_result]

    field :name, :string
    field :description, :string

    field :items, list_of(:menu_item) do
      resolve &Resolvers.Menu.items_for_category/3
    end
  end

  object :menu_item do
    interfaces [:search_result]

    field :id, :id
    field :name, :string
    field :description, :string
    field :price, :decimal
    field :added_on, :date
    field :allergy_info, list_of(:allergy_info)
  end

  object :allergy_info do
    field :allergen, :string
    field :severity, :string

    # field :allergen, :string do
    #   resolve fn parent, _, _ ->
    #     {:ok, Map.get(parent, "allergen")}
    #   end
    # end

    # field :severity, :string do
    #   resolve fn parent, _, _ ->
    #     {:ok, Map.get(parent, "severity")}
    #   end
    # end
  end

  object :menu_item_result do
    field :menu_item, :menu_item
    field :errors, list_of(:input_error)
  end

  @desc "Filtering options for the menu item list"
  input_object :menu_item_filter do
    @desc "Matching a name"
    field :name, :string

    @desc "Matching a tag"
    field :tag, :string

    @desc "Matching a category name"
    field :category, :string

    @desc "Price above value"
    field :price_above, :float

    @desc "Price below value"
    field :price_below, :float

    @desc "Added to the menu before this date"
    field :added_before, :date

    @desc "Added to the menu after this date"
    field :added_after, :date
  end

  input_object :menu_item_input do
    field :name, :string
    field :description, :string
    field :price, non_null(:decimal)
    field :category_id, non_null(:id)
  end
end
