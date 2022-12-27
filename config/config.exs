# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :twitter,
  ecto_repos: [Twitter.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :twitter, TwitterWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: TwitterWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Twitter.PubSub,
  live_view: [signing_salt: "sJT0IQHm"]

config :twitter, TwitterWeb.Guardian,
  issuer: "twitter",
  ttl: {1, :day},
  verify_issuer: true,
  secret_key: "super secret key"

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
