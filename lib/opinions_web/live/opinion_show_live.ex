defmodule OpinionsWeb.OpinionShowLive do
  use OpinionsWeb, :live_view

  alias Opinions.Accounts
  alias Opinions.Threads
  alias OpinionsWeb.Events

  def render(assigns) do
    ~H"""
    <div>
      <.link
        class="bg-gray-300 hover:bg-gray-300 text-white font-bold py-2 px-4 rounded"
        href={~p"/opinions"}
      >
        &lt; Back to list
      </.link>
    </div>

    <br />
    <br />

    <.header class="text-left">
      <%= @post.title %>
    </.header>

    <div>
      <span>
        <small>
          Posted by <strong><%= @post.author_email %></strong> on <%= @post.inserted_at %>
        </small>
      </span>
      <br />
      <br />
      <p class="mb-3 text-gray-500 dark:text-gray-400 first-line:uppercase first-line:tracking-widest first-letter:text-7xl first-letter:font-bold first-letter:text-gray-900 dark:first-letter:text-gray-100 first-letter:mr-3 first-letter:float-left">
        <%= @post.body %>
      </p>
    </div>
    <br />
    <br />
    <div class="flex space-x-4 justify-end">
      <%= if @current_user.id == @post.author_id do %>
        <.link
          class="bg-yellow-500 hover:bg-yellow-700 text-white font-bold py-2 px-4 rounded"
          href={~p"/opinions/#{@post.id}/edit"}
        >
          Edit
        </.link>
        <.button
          class="bg-red-500 hover:bg-red-700 text-white font-bold py-2 px-4 rounded"
          phx-click="delete"
          data-confirm="Are you sure?"
        >
          Delete
        </.button>
      <% end %>
    </div>
    <br />
    <hr />

    <div>
      <.simple_form for={@form} phx-change="validate" phx-submit="submit-comment">
        <.input type="hidden" name="author_id" value={@current_user.id} />
        <.input type="hidden" name="parent_id" value={@post.id} />
        <.input
          type="textarea"
          field={@form[:body]}
          label="Add a new comment (remember to be civil)"
          required
        />
        <.button class="bg-green-700 hover:bg-green-700">
          Submit
        </.button>
      </.simple_form>
    </div>

    <div>
      <br />
      <h3>
        Other comments
      </h3>

      <br />

      <table>
        <%= for comment <- @comments do %>
          <tr>
            <td><%= comment.body %></td>
          </tr>
          <tr>
            <td>
              <small>
                by <%= comment.author_email %> on <%= comment.inserted_at %>
              </small>
            </td>
          </tr>
          <tr>
            <td>&nbsp;</td>
          </tr>
        <% end %>
      </table>
    </div>
    """
  end

  def mount(params, _session, socket) do
    post_id = params["id"]

    if connected?(socket), do: Events.subscribe(post_id)

    post = Threads.get_post!(post_id)

    post =
      post
      |> Map.put(:author_email, Accounts.get_user!(post.author_id).email)

    comments = Threads.get_comments(post_id)

    form =
      to_form(
        %{
          "author_id" => socket.assigns.current_user,
          "parent_id" => post_id
        },
        as: "post"
      )

    socket =
      socket
      |> assign(:post, post)
      |> assign(:form, form)
      |> assign(:comments, comments)

    {:ok, socket}
  end

  def handle_info(%{event: "new-comment", payload: %{parent_id: parent_id}}, socket) do
    socket =
      socket
      |> assign(:comments, Threads.get_comments(parent_id))

    {:noreply, socket}
  end

  def handle_info(%{event: "post-updated"}, socket) do
    post_id = socket.assigns.post.id
    post = Threads.get_post!(post_id)

    socket =
      socket
      |> assign(:post, post)
      |> put_flash(:info, "Post has been updated!")

    {:noreply, socket}
  end

  def handle_info(%{event: "post-gone"}, socket) do
    socket =
      socket
      |> put_flash(:error, "Post removed, returned to list page!")

    {:noreply, push_navigate(socket, to: ~p"/opinions/", replace: true)}
  end

  def handle_event(
        "submit-comment",
        %{
          "author_id" => author_id,
          "parent_id" => parent_id,
          "post" => %{
            "body" => body
          }
        } = _params,
        socket
      ) do
    comment = do_create_comment(author_id, parent_id, body)

    Events.broadcast_new_comment(parent_id)

    socket =
      socket
      |> assign(:comments, [comment | socket.assigns.comments])

    {:noreply, socket}
  end

  def handle_event("delete", _params, socket) do
    post_id = socket.assigns.post.id
    {:ok, _post} = Threads.delete_post_id(post_id)

    Events.broadcast_post_gone(post_id)

    socket =
      socket
      |> put_flash(:info, "Post deleted")

    {:noreply, push_navigate(socket, to: ~p"/opinions", replace: true)}
  end

  def handle_event(_name, _params, socket), do: {:noreply, socket}

  defp do_create_comment(author_id, parent_id, body) do
    {:ok, comment} =
      Threads.create_post(%{
        author_id: Ecto.UUID.cast!(author_id),
        parent_id: Ecto.UUID.cast!(parent_id),
        title: nil,
        body: body
      })

    comment
    |> Map.put(:author_email, Accounts.get_user!(comment.author_id).email)
  end
end
