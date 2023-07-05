defmodule OpinionsWeb.OpinionsLive.ShowTest do
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

  describe "Show post page" do
    test "renders post", %{conn: conn, post: post} do
      {:ok, _lv, html} = live(conn, ~p"/opinions/#{post.id}")

      assert html =~ post.title
      assert html =~ post.body
      assert html =~ "Edit"
      assert html =~ "Delete"
    end

    test "hides edit and delete buttons if user is not the author" do
    end

    test "renders new comment is one is added (on another tab)" do
    end

    test "renders post when it's updated (on another tab)" do
    end

    test "redirects to index page if post is deleted (on another tab)" do
    end

    test "renders new comment is one is added (via the form)" do
    end

    test "redirects to index page if post is deleted (via button)" do
    end

    test "redirects to edit page if edit is pressed" do
    end

    test "redirects to index page if 'Back to list' is pressed" do
    end
  end
end
