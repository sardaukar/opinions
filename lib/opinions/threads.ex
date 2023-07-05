defmodule Opinions.Threads do
  @moduledoc """
  The Threads context.
  """

  import Ecto.Query, warn: false
  alias Opinions.Repo

  alias Opinions.Threads.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    query =
      from p in "posts",
        join: u in "users",
        on: p.author_id == u.id,
        where: is_nil(p.parent_id),
        select: %{
          id: p.id,
          body: p.body,
          title: p.title,
          author_id: p.author_id,
          inserted_at: p.inserted_at,
          parent_id: p.parent_id,
          author_email: u.email,
          comments_count:
            fragment(
              "(select count(id) from posts where parent_id == ?)",
              p.id
            )
        }

    Repo.all(query)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    query =
      from p in "posts",
        join: u in "users",
        on: p.author_id == u.id,
        where: p.id == ^id,
        select: %{
          id: p.id,
          body: p.body,
          title: p.title,
          author_id: p.author_id,
          inserted_at: p.inserted_at,
          parent_id: p.parent_id,
          author_email: u.email,
          comments_count:
            fragment(
              "(select count(id) from posts where parent_id == ?)",
              p.id
            )
        }

    Repo.one!(query)
  end

  def get_comments(parent_id) do
    query =
      from p in "posts",
        join: u in "users",
        on: p.author_id == u.id,
        where: p.parent_id == ^parent_id,
        order_by: [desc: p.inserted_at],
        select: %{
          body: p.body,
          author_id: p.author_id,
          author_email: u.email,
          inserted_at: p.inserted_at
        }

    Repo.all(query)
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(map, attrs) do
    post = struct(Post, map)

    post
    |> Post.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post by ID.

  ## Examples

      iex> delete_post_id(post_id)
      {:ok, %Post{}}

      iex> delete_post_id(post_id)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post_id(post_id) do
    %Post{id: post_id} |> Repo.delete()
  end
end
