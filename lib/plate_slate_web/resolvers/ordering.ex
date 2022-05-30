defmodule PlateSlateWeb.Resolvers.Ordering do
  alias PlateSlateWeb.Endpoint
  alias PlateSlate.Ordering
  alias Absinthe.Subscription

  def place_order(_, %{input: place_order_input}, _) do
    with {:ok, order} <- Ordering.create_order(place_order_input) do
      Subscription.publish(Endpoint, order, new_order: "*")
      {:ok, %{order: order}}
    end
  end

  def ready_order(_, %{id: id}, _), do: change_state(id, "ready")

  def complete_order(_, %{id: id}, _), do: change_state(id, "complete")

  defp change_state(id, state) do
    order = Ordering.get_order!(id)

    with {:ok, order} <- Ordering.update_order(order, %{state: state}) do
      {:ok, %{order: order}}
    end
  end
end
