defmodule TwitterWeb.Router do
  use TwitterWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_private do
    plug :api
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

    resources "/users", UserController, only: [:create, :show, :update, :delete]

    get "/users/:id/tweets", UserController, :tweets
    get "/users/:id/feed", UserController, :feed
    post "/users/:id/subscription", UserController, :subscribe
    delete "/users/:id/subscription", UserController, :unsubscribe

    resources "/tweets", TweetController, only: [:create, :show, :update, :delete]

    post "/tweets/:id/like", TweetController, :like
    delete "/tweets/:id/like", TweetController, :unlike
  end
end
