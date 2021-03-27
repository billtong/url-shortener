defmodule Shorturl.Repo do
  use Ecto.Repo,
    otp_app: :shorturl,
    adapter: Ecto.Adapters.Postgres
end
