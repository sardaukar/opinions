defmodule Opinions.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      OpinionsWeb.Telemetry,
      Opinions.Repo,
      {Phoenix.PubSub, name: Opinions.PubSub},
      {Finch, name: Opinions.Finch},
      OpinionsWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Opinions.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    OpinionsWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
