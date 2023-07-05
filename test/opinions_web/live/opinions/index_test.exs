defmodule OpinionsWeb.OpinionsLive.IndexTest do
  use OpinionsWeb.ConnCase

  import Phoenix.LiveViewTest
  import Opinions.AccountsFixtures
  import Opinions.ThreadsFixtures

  alias Opinions.Threads

  setup %{conn: conn} do
    current_user = user_fixture(%{username: "bantunes"})
    conn = log_in_user(conn, current_user)

    {:ok, conn: conn, current_user: current_user}
  end

  describe "Opinions page" do
    test "renders page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/opinions")

      assert html =~ "Opinions"
      assert html =~ "Add new post"
    end

    test "redirects to edit page when clicking 'Add new post'", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/opinions")

      assert lv
             |> element("#add-new-post")
             |> render_click()
             |> follow_redirect(conn, ~p"/opinions/new")
    end

    test "renders list of posts present", %{conn: conn, current_user: current_user} do
      post = post_fixture(%{title: "First post!", author_id: current_user.id})

      {:ok, _lv, html} = live(conn, ~p"/opinions")

      assert html =~ "First post!"

      assert comment_count(html, post.id) == 0
    end

    test "renders list of posts present and correct comments count", %{
      conn: conn,
      current_user: current_user
    } do
      post = post_fixture(%{title: "First post!", author_id: current_user.id})
      _comment = comment_fixture(post, %{title: "First comment!", author_id: current_user.id})

      {:ok, _lv, html} = live(conn, ~p"/opinions")

      assert html =~ "First post!"

      assert comment_count(html, post.id) == 1
    end

    test "renders updates to post titles", %{
      conn: conn,
      current_user: current_user
    } do
      post = post_fixture(%{title: "First post!", author_id: current_user.id})
      _comment = comment_fixture(post, %{title: "First comment!", author_id: current_user.id})

      {:ok, lv, html} = live(conn, ~p"/opinions")

      assert html =~ "First post!"

      {:ok, _updated_post} = Threads.update_post(post, %{title: "First post (updated)"})

      send(lv.pid, %{event: "updated-post"})
      assert render(lv) =~ "First post (updated)"
    end

    test "renders updates to commnent count", %{
      conn: conn,
      current_user: current_user
    } do
      post = post_fixture(%{title: "First post!", author_id: current_user.id})
      _comment = comment_fixture(post, %{title: "First comment!", author_id: current_user.id})

      {:ok, lv, html} = live(conn, ~p"/opinions")

      assert html =~ "First post!"

      assert comment_count(html, post.id) == 1

      {:ok, _new_comment} =
        Threads.create_post(%{
          body: "And another one",
          parent_id: post.id,
          author_id: current_user.id
        })

      send(lv.pid, %{event: "updated-comment-count"})
      new_html = render(lv)

      assert comment_count(new_html, post.id) == 2
    end

    test "renders updated list when post is added", %{
      conn: conn,
      current_user: current_user
    } do
      _post = post_fixture(%{title: "First post!", author_id: current_user.id})

      {:ok, lv, html} = live(conn, ~p"/opinions")

      assert html =~ "First post!"

      _second_post = post_fixture(%{title: "Second post!", author_id: current_user.id})

      send(lv.pid, %{event: "new-post"})
      new_html = render(lv)

      assert new_html =~ "First post!"
      assert new_html =~ "Second post!"
    end

    test "renders updated list when post is deleted", %{
      conn: conn,
      current_user: current_user
    } do
      post = post_fixture(%{title: "First post!", author_id: current_user.id})

      {:ok, lv, html} = live(conn, ~p"/opinions")

      assert html =~ "First post!"

      Threads.delete_post_id(post.id)

      send(lv.pid, %{event: "deleted-post"})
      new_html = render(lv)

      refute new_html =~ "First post!"
    end
  end

  defp comment_count(html, row_id) do
    [{_element, _style, content}] =
      html |> Floki.find("tr##{row_id} :last-child :last-child :nth-child(2)")

    {int, ""} = String.trim(hd(content)) |> Integer.parse()

    int
  end
end
