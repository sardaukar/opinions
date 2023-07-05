defmodule OpinionsWeb.OpinionsLive.EditTest do
  use OpinionsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Opinions.AccountsFixtures
  import Opinions.ThreadsFixtures

  setup %{conn: conn} do
    current_user = user_fixture(%{username: "bantunes"})
    post = post_fixture(%{author_id: current_user.id, title: "some title", body: "some body"})
    conn = log_in_user(conn, current_user)

    {:ok, conn: conn, current_user: current_user, post: post}
  end

  describe "Edit post page" do
    test "renders post", %{conn: conn, post: post} do
      {:ok, _lv, html} = live(conn, ~p"/opinions/#{post.id}/edit")

      assert html =~ "Edit post"
      assert html =~ post.title
      assert html =~ post.body
    end

    test "returns to post if 'Back to post' is clicked" do
    end

    test "shows validation error if fields empty" do
    end

    test "redirects to show page when update is complete" do
    end

    test "redirects to index page if post is deleted" do
    end
  end
end
