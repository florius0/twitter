defmodule TwitterWeb.TweetController do
  use TwitterWeb, :controller

  alias Twitter.Tweets
  alias Twitter.Tweets.Policies

  action_fallback TwitterWeb.FallbackController

  def index(conn, _params) do
    with tweets <- Tweets.list_tweets(),
         {:ok, _user} <- Policies.list(Guardian.Plug.current_resource(conn), tweets) do
      render(conn, "index.json", tweets: tweets)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, tweet} <- Tweets.get_tweet(id),
         {:ok, _user} <- Policies.show(Guardian.Plug.current_resource(conn), tweet) do
      render(conn, "show.json", tweet: tweet)
    end
  end

  def create(conn, %{"tweet" => tweet_params}) do
    with {:ok, user} <- Policies.create(Guardian.Plug.current_resource(conn), tweet_params),
         {:ok, tweet} <- Tweets.create_tweet(tweet_params, user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.tweet_path(conn, :show, tweet))
      |> render("show.json", tweet: tweet)
    end
  end

  def reply(conn, %{"id" => id, "tweet" => tweet_params}) do
    with {:ok, reply_to} <- Tweets.get_tweet(id),
         {:ok, user} <- Policies.reply(Guardian.Plug.current_resource(conn), reply_to),
         {:ok, tweet} <- Tweets.create_tweet(tweet_params, user, reply_to) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.tweet_path(conn, :show, tweet))
      |> render("show.json", tweet: tweet)
    end
  end

  def like(conn, %{"id" => id}) do
    with {:ok, tweet} <- Tweets.get_tweet(id),
         {:ok, user} <- Policies.like(Guardian.Plug.current_resource(conn), tweet),
         {:ok, tweet} <- Tweets.like_tweet(tweet, user) do
      render(conn, "show.json", tweet: tweet)
    end
  end

  def unlike(conn, %{"id" => id}) do
    with {:ok, tweet} <- Tweets.get_tweet(id),
         {:ok, user} <- Policies.unlike(Guardian.Plug.current_resource(conn), tweet),
         {:ok, tweet} <- Tweets.unlike_tweet(tweet, user) do
      render(conn, "show.json", tweet: tweet)
    end
  end

  def delete(conn, %{"id" => id}) do
    with {:ok, tweet} <- Tweets.get_tweet(id),
         {:ok, _user} <- Policies.delete(Guardian.Plug.current_resource(conn), tweet),
         {:ok, tweet} <- Tweets.delete_tweet(tweet) do
      render(conn, "show.json", tweet: tweet)
    end
  end
end
