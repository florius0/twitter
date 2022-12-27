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
      tweets: user.tweets && render_many(user.tweets, TwitterWeb.TweetView, "tweet.json"),
      followers: user.followers && render_many(user.followers, UserView, "user.json"),
      followees: user.followees && render_many(user.followees, UserView, "user.json"),
      likes: user.likes && render_many(user.likes, TwitterWeb.TweetView, "tweet.json")
    }
  end
end
