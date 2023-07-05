defmodule Opinions.ThreadsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Opinions.Threads` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Opinions.Threads.create_post()

    Opinions.Threads.get_post!(post.id)
  end

  @doc """
  Generate a comment for a given post.
  """
  def comment_fixture(parent_post, attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body",
        parent_id: parent_post.id
      })
      |> Opinions.Threads.create_post()

    Opinions.Threads.get_post!(comment.id)
  end
end
