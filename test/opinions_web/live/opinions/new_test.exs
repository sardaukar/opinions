defmodule OpinionsWeb.OpinionsLive.NewTest do
  use OpinionsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Opinions.AccountsFixtures

  setup %{conn: conn} do
    current_user = user_fixture(%{username: "bantunes"})
    conn = log_in_user(conn, current_user)

    {:ok, conn: conn, current_user: current_user}
  end

  describe "New post page" do
    test "renders page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/opinions/new")

      assert html =~ "Add new post"
    end

    test "shows validation error if form is empty" do
    end

    test "redirects to post page when form is submitted" do
    end

    test "redirects to index page if 'Back to list' is pressed" do
    end
  end
end
