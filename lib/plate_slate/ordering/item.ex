defmodule PlateSlate.Ordering.Item do
  use Ecto.Schema

  import Ecto.Changeset

  @required_fields ~w(name price quantity)a

  embedded_schema do
    field :price, :decimal
    field :name, :string
    field :quantity, :integer
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
