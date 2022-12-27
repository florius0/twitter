defmodule TwitterWeb.TweetView do
  use TwitterWeb, :view

  alias Twitter.Tweets.Tweet
  alias Twitter.Users.User

  alias TwitterWeb.TweetView

  def render("index.json", %{tweets: tweets}) do
    %{data: render_many(tweets, TweetView, "tweet.json")}
  end

  def render("show.json", %{tweet: tweet}) do
    %{data: render_one(tweet, TweetView, "tweet.json")}
  end

  def render("tweet.json", %{tweet: tweet}) do
    %{
      id: tweet.id,
      text: tweet.text,
      author: render_user(tweet.author),
      reply_to: render_tweet(tweet.reply_to),
      likes: render_users(tweet.likes),
      replies: render_tweets(tweet.replies),
      inserted_at: tweet.inserted_at,
      updated_at: tweet.updated_at
    }
  end

  defp render_tweet(%Tweet{} = tweet), do: render_one(tweet, TweetView, "tweet.json")
  defp render_tweet(_), do: nil

  defp render_tweets(tweets) when is_list(tweets), do: render_many(tweets, TweetView, "tweet.json")
  defp render_tweets(_), do: nil

  defp render_user(%User{} = user), do: render_one(user, TwitterWeb.UserView, "user.json")
  defp render_user(_), do: nil

  defp render_users(users) when is_list(users), do: render_many(users, TwitterWeb.UserView, "user.json")
  defp render_users(_), do: nil
end
