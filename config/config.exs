# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :shorturl,
  ecto_repos: [Shorturl.Repo],
  link_cache_name: :link_cache_server, # the name of the link cache genserver
  link_cache_ets: :link_cache # the name of the ets in cache genserver

# Configures the endpoint
config :shorturl, ShorturlWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "EbqORUUbOEF25r380yYMm3GXp+FJMwt1XkLzYwc9lrb/fzqhNMzGV1nWnf5NQbXw",
  render_errors: [view: ShorturlWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Shorturl.PubSub,
  live_view: [signing_salt: "EKQYmi6w"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :shorturl, Shorturl.Scheduler,
  jobs: [
    # Every minute
    {"@daily", {Shorturl.Clean, :delete_old_links, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
