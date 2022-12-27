defmodule TwitterWeb.UserView do
  use TwitterWeb, :view
  alias TwitterWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      tweets: render_tweets(user.tweets),
      followers: render_users(user.followers),
      followees: render_users(user.followees),
      likes: render_tweets(user.likes),
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end

  defp render_tweets(tweets) when is_list(tweets), do: render_many(tweets, TwitterWeb.TweetView, "tweet.json")
  defp render_tweets(_), do: nil

  defp render_users(users) when is_list(users), do: render_many(users, UserView, "user.json")
  defp render_users(_), do: nil
end
