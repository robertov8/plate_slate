defmodule PlateSlate.Ordering.Order do
  use Ecto.Schema

  import Ecto.Changeset

  @required_fields ~w(customer_number ordered_at state)a

  schema "orders" do
    field :customer_number, :integer, read_after_writes: true
    field :ordered_at, :utc_datetime, read_after_writes: true
    field :state, :string, read_after_writes: true

    embeds_many :items, PlateSlate.Ordering.Item

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, @required_fields)
    |> cast_embed(:items)
  end
end
