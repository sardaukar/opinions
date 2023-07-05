defmodule OpinionsWeb.Events do
  @moduledoc """
  Module handling all broadcasting of events related to Opinions lifecycle
  """

  def subscribe_posts do
    OpinionsWeb.Endpoint.subscribe("posts")
  end

  def subscribe(post_id) do
    OpinionsWeb.Endpoint.subscribe(topic(post_id))
  end

  def broadcast_new_post, do: OpinionsWeb.Endpoint.broadcast("posts", "new-post", %{})

  def broadcast_post_updated(post_id) do
    OpinionsWeb.Endpoint.broadcast(topic(post_id), "post-updated", %{})
    OpinionsWeb.Endpoint.broadcast("posts", "updated-post", %{})
  end

  def broadcast_new_comment(parent_id) do
    OpinionsWeb.Endpoint.broadcast(topic(parent_id), "new-comment", %{parent_id: parent_id})
    OpinionsWeb.Endpoint.broadcast("posts", "updated-comment-count", %{})
  end

  def broadcast_post_gone(post_id) do
    OpinionsWeb.Endpoint.broadcast(topic(post_id), "post-gone", %{})
    OpinionsWeb.Endpoint.broadcast("posts", "deleted-post", %{})
  end

  defp topic(id), do: "comment:#{id}"
end
