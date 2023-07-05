defmodule OpinionsWeb.OpinionEditLive do
  use OpinionsWeb, :live_view

  alias Opinions.Accounts
  alias Opinions.Threads
  alias OpinionsWeb.Events

  def render(assigns) do
    ~H"""
    <div>
      <.link
        class="bg-gray-300 hover:bg-gray-300 text-white font-bold py-2 px-4 rounded"
        href={~p"/opinions/#{@post.id}"}
      >
        &lt; Back to post
      </.link>
    </div>

    <br />
    <br />

    <.header class="text-left">
      Edit post
    </.header>

    <div>
      <.simple_form for={@form} phx-change="validate" phx-submit="submit-update" id="edit-form">
        <.input type="hidden" name="id" value={@post.id} />
        <.input type="text" field={@form[:title]} label="Title" required />

        <.input type="textarea" field={@form[:body]} label="Body" required />
        <.button class="bg-green-700 hover:bg-green-700">
          Save
        </.button>
      </.simple_form>
    </div>
    """
  end

  def mount(params, _session, socket) do
    post_id = params["id"]

    if connected?(socket), do: Events.subscribe(post_id)

    post = Threads.get_post!(post_id)

    if socket.assigns.current_user.id != post.author_id do
      socket =
        socket
        |> put_flash(:error, "You can't edit a post you didn't create")

      {:ok, push_navigate(socket, to: ~p"/opinions/", replace: true)}
    else
      form =
        to_form(
          %{
            "id" => post.id,
            "author_id" => post.author_id,
            "parent_id" => post.parent_id,
            "title" => post.title,
            "body" => post.body
          },
          as: "post"
        )

      socket =
        socket
        |> assign(:post, post)
        |> assign(:form, form)

      {:ok, socket}
    end
  end

  def handle_info(%{event: "post-gone"}, socket) do
    socket =
      socket
      |> put_flash(:error, "Post removed, returned to list page!")

    {:noreply, push_navigate(socket, to: ~p"/opinions/", replace: true)}
  end

  def handle_event(
        "submit-update",
        %{
          "post" => %{
            "title" => title,
            "body" => body
          }
        } = _params,
        socket
      ) do
    post_id = socket.assigns.post.id

    _updated_post = do_update_post(post_id, title, body)

    Events.broadcast_post_updated(post_id)

    socket =
      socket
      |> put_flash(:info, "Post updated successfully!")

    {:noreply, push_navigate(socket, to: ~p"/opinions/#{post_id}", replace: true)}
  end

  def handle_event(_name, _params, socket), do: {:noreply, socket}

  defp do_update_post(id, title, body) do
    post = Threads.get_post!(id)

    {:ok, updated_post} =
      Threads.update_post(post, %{
        title: title,
        body: body
      })

    updated_post
    |> Map.put(:author_email, Accounts.get_user!(updated_post.author_id).email)
  end
end
