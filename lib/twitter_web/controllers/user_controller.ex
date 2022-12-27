defmodule TwitterWeb.UserController do
  use TwitterWeb, :controller

  alias Twitter.Users
  alias Twitter.Tweets
  alias Twitter.Users.Policies

  action_fallback TwitterWeb.FallbackController

  def index(conn, _params) do
    with users <- Users.list_users(),
         {:ok, _user} <- Policies.list(Guardian.Plug.current_resource(conn), users) do
      render(conn, "index.json", users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Users.get_user(id),
         {:ok, _user} <- Policies.show(Guardian.Plug.current_resource(conn), user) do
      render(conn, "show.json", user: user)
    end
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, _} <- Policies.create(Guardian.Plug.current_resource(conn), user_params),
         {:ok, user} <- Users.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    with {:ok, user} <- Users.get_user(id),
         {:ok, _user} <- Policies.update(Guardian.Plug.current_resource(conn), user),
         {:ok, user} <- Users.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, user} <- Users.get_user(id),
         {:ok, _user} <- Policies.delete(Guardian.Plug.current_resource(conn), user),
         {:ok, user} <- Users.delete_user(user) do
      render(conn, "show.json", user: user)
    end
  end

  def subscribe(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, user} <- Users.get_user(id),
         {:ok, _user} <- Policies.subscribe(current_user, user),
         {:ok, user} <- Users.subscribe(current_user, user) do
      render(conn, "show.json", user: user)
    else
      {:error, :already_subscribed} ->
        conn
        |> put_status(:conflict)
        |> render(TwitterWeb.ErrorView, "error.json", message: "Already subscribed")

      {:error, :cannot_subscribe_to_self} ->
        conn
        |> put_status(:conflict)
        |> render(TwitterWeb.ErrorView, "error.json", message: "Cannot subscribe to self")

      error ->
        error
    end
  end

  def unsubscribe(conn, %{"id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)

    with {:ok, user} <- Users.get_user(id),
         {:ok, _user} <- Policies.unsubscribe(current_user, user),
         {:ok, user} <- Users.unsubscribe(current_user, user) do
      render(conn, "show.json", user: user)
    else
      {:error, :not_subscribed} ->
        conn
        |> put_status(:conflict)
        |> render(TwitterWeb.ErrorView, "error.json", message: "Not subscribed")

      {:error, :cannot_unsubscribe_from_self} ->
        conn
        |> put_status(:conflict)
        |> render(TwitterWeb.ErrorView, "error.json", message: "Cannot unsubscribe from self")

      error ->
        error
    end
  end

  def feed(conn, %{"id" => id}) do
    with {:ok, user} <- Users.get_user(id),
         {:ok, _user} <- Policies.feed(Guardian.Plug.current_resource(conn), user),
         tweets <- Tweets.get_feed(user) do
      conn
      |> put_view(TwitterWeb.TweetView)
      |> render("index.json", tweets: tweets)
    end
  end

  def likes(conn, %{"id" => id}) do
    with {:ok, user} <- Users.get_user(id),
         {:ok, _user} <- Policies.likes(Guardian.Plug.current_resource(conn), user),
         tweets <- Tweets.list_liked_tweets(user) do
      conn
      |> put_view(TwitterWeb.TweetView)
      |> render("index.json", tweets: tweets)
    end
  end
end
