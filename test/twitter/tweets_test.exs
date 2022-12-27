defmodule Twitter.TweetsTest do
  use Twitter.DataCase

  alias Twitter.Tweets
  alias Twitter.Users

  describe "tweets" do
    alias Twitter.Tweets.Tweet
    alias Twitter.Users.User

    import Twitter.{TweetsFixtures, UsersFixtures}

    test "list_tweets/0 returns all tweets" do
      tweet = tweet_fixture()
      assert Tweets.list_tweets() == [tweet]
    end

    test "get_tweet/1 returns the tweet with given id" do
      tweet_id = tweet_fixture().id

      assert {:ok, %Tweet{id: ^tweet_id}} = Tweets.get_tweet(tweet_id)
    end

    test "get_tweet/1 traverses reply tree" do
      user = user_fixture()
      {:ok, tweet1} = Tweets.create_tweet(%{text: "1"}, user)
      {:ok, tweet2} = Tweets.create_tweet(%{text: "2"}, user, tweet1)
      {:ok, tweet3} = Tweets.create_tweet(%{text: "3"}, user, tweet2)

      tweet1_id = tweet1.id
      tweet2_id = tweet2.id
      tweet3_id = tweet3.id

      assert {:ok, %Tweet{replies: [%Tweet{id: ^tweet1_id}, %Tweet{id: ^tweet2_id}, %Tweet{id: ^tweet3_id}]}} = Tweets.get_tweet(tweet1.id)
    end

    test "create_tweet/1 with valid data creates a tweet" do
      user = user_fixture()
      assert {:ok, %Tweet{} = tweet} = Tweets.create_tweet(%{text: "Hello world!"}, user)
      assert tweet.author_id == user.id
      assert tweet.text == "Hello world!"
    end

    test "create_tweet/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Tweets.create_tweet(%{}, user)
    end

    test "update_tweet/2 with valid data updates the tweet" do
      tweet = tweet_fixture()
      assert {:ok, %Tweet{} = tweet} = Tweets.update_tweet(tweet, %{text: "Hello world!"})
      assert tweet.text == "Hello world!"
    end

    test "update_tweet/2 with invalid data returns error changeset" do
      tweet = tweet_fixture()
      assert {:error, %Ecto.Changeset{}} = Tweets.update_tweet(tweet, %{text: nil})
    end

    test "delete_tweet/1 deletes the tweet" do
      tweet = tweet_fixture()
      assert {:ok, %Tweet{}} = Tweets.delete_tweet(tweet)
      assert {:error, _} = Tweets.get_tweet(tweet.id)
    end

    test "delete_tweet/1 returns an error when tweet does not exist" do
      assert {:error, _} = Tweets.delete_tweet(%Tweet{id: Ecto.UUID.generate()})
    end

    test "list_tweets_for_user/1 returns the list of tweets for the given user" do
      user = user_fixture()

      {:ok, tweet1} = Tweets.create_tweet(%{text: "Hello world!"}, user)
      :timer.sleep(1000)
      {:ok, tweet2} = Tweets.create_tweet(%{text: "Hello world!"}, user)

      tweet1_id = tweet1.id
      tweet2_id = tweet2.id

      assert [%Tweet{id: ^tweet2_id}, %Tweet{id: ^tweet1_id}] = Tweets.list_tweets_for_user(user)
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
      :timer.sleep(1000)
      assert {:ok, _} = Tweets.like_tweet(tweet2, user)

      assert [%Tweet{id: ^tweet2_id}, %Tweet{id: ^tweet1_id}] = Tweets.list_liked_tweets(user)
    end

    test "get_feed/1 returns the feed for the given user" do
      user = user_fixture()

      tweet1 = tweet_fixture()
      :timer.sleep(1000)
      tweet2 = tweet_fixture()

      tweet1_id = tweet1.id
      tweet2_id = tweet2.id

      assert {:ok, _} = Users.subscribe(user, tweet1.author)
      assert {:ok, _} = Users.subscribe(user, tweet2.author)

      assert [%Tweet{id: ^tweet2_id}, %Tweet{id: ^tweet1_id}] = Tweets.get_feed(user)
    end
  end
end
