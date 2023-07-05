defmodule Opinions.Repo do
  use Ecto.Repo,
    otp_app: :opinions,
    adapter: Ecto.Adapters.SQLite3
end
