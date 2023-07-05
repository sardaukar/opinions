defmodule Opinions.ThreadsTest do
  use Opinions.DataCase

  alias Opinions.Threads

  describe "posts" do
    alias Opinions.Threads.Post

    import Opinions.ThreadsFixtures
    import Opinions.AccountsFixtures

    @invalid_attrs %{body: nil}

    test "list_posts/0 returns all posts" do
      user = user_fixture()
      post = post_fixture(%{body: "some body", author_id: user.id})

      post_ids = Enum.map(Threads.list_posts(), & &1.id)

      assert Enum.member?(post_ids, post.id)
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(%{body: "some body", author_id: user.id})

      assert Threads.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()
      valid_attrs = %{body: "some body", author_id: user.id}

      assert {:ok, %Post{} = post} = Threads.create_post(valid_attrs)
      assert post.body == "some body"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Threads.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      user = user_fixture()
      post = post_fixture(%{body: "some body", title: "some title", author_id: user.id})

      update_attrs = %{body: "some updated body"}

      assert {:ok, %Post{} = post} = Threads.update_post(post, update_attrs)
      assert post.body == "some updated body"
    end

    test "update_post/2 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(%{body: "some body", author_id: user.id})

      assert {:error, %Ecto.Changeset{}} = Threads.update_post(post, @invalid_attrs)
      assert post == Threads.get_post!(post.id)
    end

    test "delete_post_id/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(%{body: "some body", author_id: user.id})

      assert {:ok, %Post{}} = Threads.delete_post_id(post.id)

      assert_raise Ecto.NoResultsError, fn -> Threads.get_post!(post.id) end
    end
  end
end
