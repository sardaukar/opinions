defmodule OpinionsWeb.OpinionIndexLive do
  use OpinionsWeb, :live_view

  alias Opinions.Threads
  alias OpinionsWeb.Events

  def render(assigns) do
    ~H"""
    <div>
      <.header class="text-left">
        Opinions
      </.header>
    </div>

    <div>
      <.table id="posts" rows={@posts} row_id={&row_id/1}>
        <:col :let={post} label="Title">
          <.link href={~p"/opinions/#{post.id}"}><%= post.title %> ↗</.link>
        </:col>
        <:col :let={post} label="Author">
          <%= post.author_email %>
        </:col>
        <:col :let={post} label="Created">
          <%= post.inserted_at %>
        </:col>
        <:col :let={post} label="Comments">
          <%= post.comments_count %>
        </:col>
      </.table>

      <hr />
      <br />
      <.link
        class="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"
        id="add-new-post"
        href={~p"/opinions/new"}
      >
        Add new post
      </.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Events.subscribe_posts()

    posts = Threads.list_posts()

    socket =
      socket
      |> assign(:posts, posts)

    {:ok, socket}
  end

  def handle_info(%{event: "updated-comment-count"}, socket), do: do_refresh(socket)
  def handle_info(%{event: "updated-post"}, socket), do: do_refresh(socket)
  def handle_info(%{event: "new-post"}, socket), do: do_refresh(socket)
  def handle_info(%{event: "deleted-post"}, socket), do: do_refresh(socket)

  def handle_event(_name, _params, socket), do: {:noreply, socket}

  defp do_refresh(socket) do
    posts = Threads.list_posts()

    socket =
      socket
      |> assign(:posts, posts)

    {:noreply, socket}
  end

  defp row_id(opts), do: opts.id
end
