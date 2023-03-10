defmodule Twitter.TweetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Twitter.Tweets` context.
  """

  @doc """
  Generate a tweet.
  """
  def tweet_fixture(attrs \\ %{}) do
    user = Twitter.UsersFixtures.user_fixture()

    {:ok, tweet} =
      attrs
      |> Enum.into(%{text: "some text"})
      |> Twitter.Tweets.create_tweet(user)

    tweet
  end
end
