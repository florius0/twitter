defmodule TwitterWeb.TweetView do
  use TwitterWeb, :view
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
      author: render_one(tweet.author, TwitterWeb.UserView, "user.json"),
      reply_to: tweet.reply_to && render_one(tweet.reply_to, TweetView, "tweet.json"),
      likes: tweet.likes && render_many(tweet.likes, TwitterWeb.UserView, "user.json"),
      replies: tweet.replies && render_many(tweet.replies, TweetView, "tweet.json")
    }
  end
end
