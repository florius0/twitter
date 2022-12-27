defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug TwitterWeb.Guardian.Pipeline
  end

  pipeline :api_private do
    plug :api
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api", TwitterWeb do
    pipe_through :api

    resources "/users", UserController, only: [:create]
    resources "/sessions", SessionController, only: [:create, :delete], singleton: true
  end

  scope "/api", TwitterWeb do
    pipe_through :api_private

    patch "/sessions", SessionController, :update
    put "/sessions", SessionController, :update

    resources "/users", UserController, only: [:show, :update, :delete]

    get "/users/:id/tweets", UserController, :tweets
    get "/users/:id/feed", UserController, :feed
    post "/users/:id/subscription", UserController, :subscribe
    delete "/users/:id/subscription", UserController, :unsubscribe

    resources "/tweets", TweetController

    post "/tweets/:id/like", TweetController, :like
    delete "/tweets/:id/like", TweetController, :unlike

    post "/tweets/:id/reply", TweetController, :reply
  end
end
