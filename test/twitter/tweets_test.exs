defmodule Twitter.TweetsTest do
  use Twitter.DataCase

  alias Twitter.Tweets
  alias Twitter.Users

  describe "tweets" do
    alias Twitter.Tweets.Tweet
    alias Twitter.Users.User

    import Twitter.{TweetsFixtures, UsersFixtures}

    @invalid_attrs %{text: nil}

    test "list_tweets/0 returns all tweets" do
      tweet = tweet_fixture()
      assert Tweets.list_tweets() == [tweet]
    end

    test "get_tweet/1 returns the tweet with given id" do
      tweet = tweet_fixture()
      assert {:ok, tweet} = Tweets.get_tweet(tweet.id)
    end

    test "like_tweet/2 likes the tweet" do
      tweet = tweet_fixture()
      user = user_fixture()

      tweet_id = tweet.id
      user_id = user.id

      assert {:ok, %Tweet{id: ^tweet_id} = tweet} = Tweets.like_tweet(tweet, user)
      assert [%User{id: ^user_id}] = tweet.likes
    end

    test "like_tweet/2 returns an error when the user has already liked the tweet" do
      tweet = tweet_fixture()
      user = user_fixture()

      assert {:ok, _tweet} = Tweets.like_tweet(tweet, user)
      assert {:error, :already_liked} = Tweets.like_tweet(tweet, user)
    end

    test "unlike_tweet/2 unlikes the tweet" do
      tweet = tweet_fixture()
      user = user_fixture()

      assert {:ok, _tweet} = Tweets.like_tweet(tweet, user)

      assert {:ok, tweet} = Tweets.unlike_tweet(tweet, user)
      assert [] == tweet.likes
    end

    test "unlike_tweet/2 returns an error when the user has not liked the tweet" do
      tweet = tweet_fixture()
      user = user_fixture()

      assert {:error, :not_found} = Tweets.unlike_tweet(tweet, user)
    end

    test "list_liked_tweets/1 returns the list of liked tweets for the given user" do
      user = user_fixture()
      tweet1 = tweet_fixture()
      tweet2 = tweet_fixture()

      tweet1_id = tweet1.id
      tweet2_id = tweet2.id

      assert {:ok, _} = Tweets.like_tweet(tweet1, user)
      assert {:ok, _} = Tweets.like_tweet(tweet2, user)

      assert [%Tweet{id: ^tweet1_id}, %Tweet{id: ^tweet2_id}] = Tweets.list_liked_tweets(user)
    end

    test "get_feed/1 returns the feed for the given user" do
      user = user_fixture()
      tweet1 = tweet_fixture()
      tweet2 = tweet_fixture()

      tweet1_id = tweet1.id
      tweet2_id = tweet2.id

      assert {:ok, _} = Users.subscribe(user, tweet1.author)
      assert {:ok, _} = Users.subscribe(user, tweet2.author)

      assert [%Tweet{id: tweet2_id}, %Tweet{id: tweet1_id}] = Tweets.get_feed(user)
    end
  end
end
