defmodule Traceify.StorageAreas.StorageArea do
  use Ecto.Schema
  import Ecto.Changeset


  schema "storage_areas" do
    field :url, :string
    field :name, :string
    field :root_path, :string

    timestamps()
  end

  @doc false
  def changeset(storage_area, attrs) do
    storage_area
    |> cast(attrs, [:name, :url, :root_path])
    |> validate_required([:name, :url, :root_path])
  end
end
