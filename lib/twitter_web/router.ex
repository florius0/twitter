defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TwitterWeb do
    pipe_through :api
  end
end
