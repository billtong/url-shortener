defmodule Shorturl.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Shorturl.Repo,
      # Start the Telemetry supervisor
      ShorturlWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Shorturl.PubSub},
      # Start the Endpoint (http/https)
      ShorturlWeb.Endpoint,
      # Start a worker by calling: Shorturl.Worker.start_link(arg)
      # {Shorturl.Worker, arg}
      Shorturl.Scheduler,
      # Start Cache server
      {Shorturl.Cache, [
        server_name: Application.get_env(:shorturl, :link_cache_name),
        ets_name: Application.get_env(:shorturl, :link_cache_ets),
        ttl: :timer.seconds(60*60*24*3), #cache data save for 3 days
        ttl_check_interval: :timer.seconds(60* 10), # purge every 10 minutes
        max_size: 1_000 # the maximum cache data is 1_000
      ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Shorturl.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ShorturlWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
