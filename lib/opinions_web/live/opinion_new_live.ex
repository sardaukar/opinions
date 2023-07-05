defmodule OpinionsWeb.OpinionNewLive do
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
      Add new post
    </.header>

    <div>
      <.simple_form for={@form} phx-change="validate" phx-submit="submit-new">
        <.input type="hidden" name="author_id" value={@current_user.id} />
        <.input type="text" field={@form[:title]} label="Title" required />

        <.input type="textarea" field={@form[:body]} label="Body" required />
        <.button class="bg-green-700 hover:bg-green-700">
          Submit
        </.button>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    form =
      to_form(
        %{
          "title" => "",
          "body" => ""
        },
        as: "post"
      )

    socket =
      socket
      |> assign(:form, form)

    {:ok, socket}
  end

  def handle_event(
        "submit-new",
        %{
          "author_id" => author_id,
          "post" => %{
            "title" => title,
            "body" => body
          }
        } = _params,
        socket
      ) do
    comment = do_create_post(author_id, title, body)

    Events.broadcast_new_post()

    socket =
      socket
      |> put_flash(:info, "Post created successfully!")

    {:noreply, push_navigate(socket, to: ~p"/opinions/#{comment.id}", replace: true)}
  end

  def handle_event(_name, _params, socket), do: {:noreply, socket}

  defp do_create_post(author_id, title, body) do
    {:ok, comment} =
      Threads.create_post(%{
        author_id: Ecto.UUID.cast!(author_id),
        parent_id: nil,
        title: title,
        body: body
      })

    comment
    |> Map.put(:author_email, Accounts.get_user!(author_id).email)
  end
end
