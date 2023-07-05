defmodule Opinions.Threads.Post do
  @moduledoc """
  Schema and changesets for a Post in the Threads context
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :body, :string
    field :author_id, :binary_id
    field :parent_id, :binary_id
    field :author_email, :string, virtual: true
    field :comments_count, :integer, virtual: true

    timestamps()
  end

  @doc false
  def creation_changeset(post, attrs) do
    post
    |> cast(attrs, [:author_id, :parent_id, :body, :title])
    |> validate_required([:body, :author_id])
  end

  @doc false
  def update_changeset(post, attrs) do
    post
    |> cast(attrs, [:id, :body, :title])
    |> validate_required([:id, :body, :title])
  end
end
