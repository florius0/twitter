defmodule Twitter.Tweets do
  @moduledoc """
  The Tweets context.
  """

  import Ecto.Query, except: [preload: 2], warn: false
  alias Twitter.Repo

  alias Twitter.Tweets.{Tweet, Like}
  alias Twitter.Users.User

  @doc false
  def preload(tweet, opts \\ []), do: Repo.preload(tweet, preloads(), opts)

  @doc false
  def preloads, do: [:author, :likes, :replies]

  @doc """
  Returns the list of tweets.

  ## Examples

      iex> list_tweets()
      [%Tweet{}, ...]

  """
  @spec list_tweets :: [Tweet.t()]
  def list_tweets do
    Tweet
    |> Repo.all()
    |> preload()
  end

  @doc """
  Returns the list of tweets for the given user.
  """
  @spec list_tweets_for_user(User.t()) :: [Tweet.t()]
  def list_tweets_for_user(user) do
    Tweet
    |> where(author_id: ^user.id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single tweet.

  Loads the tweet's author and replies.

  ## Examples

      iex> get_tweet(uuid)
      {:ok, %Tweet{}}

      iex> get_tweet(uuid)
      {:error, :not_found}
  """
  @spec get_tweet(Ecto.UUID.t(), non_neg_integer()) :: {:ok, Tweet.t()} | {:error, :not_found}
  def get_tweet(id, depth \\ 1000) do
    Tweet
    |> Repo.get(id)
    |> case do
      nil ->
        {:error, :not_found}

      tweet ->
        replies =
          tweet
          |> descendants(depth)
          |> Repo.all()
          |> preload()

        {:ok, tweet |> preload() |> struct(replies: replies)}
    end
  end

  @doc """
  Creates a tweet.

  ## Examples

      iex> create_tweet(%{field: value}, %User{})
      {:ok, %Tweet{}}

      iex> create_tweet(%{field: bad_value}, %User{})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_tweet(map(), User.t(), Tweet.t() | nil) ::
          {:ok, Tweet.t()} | {:error, Ecto.Changeset.t()}
  def create_tweet(attrs, %User{} = author, reply_to \\ nil) do
    a = %{author_id: author.id, reply_to_id: reply_to && reply_to.id}

    %Tweet{}
    |> Tweet.changeset(attrs)
    |> Ecto.Changeset.cast(a, [:author_id, :reply_to_id])
    |> Repo.insert()
    |> case do
      {:ok, tweet} ->
        {:ok, preload(tweet)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a tweet.

  ## Examples

      iex> update_tweet(tweet, %{field: new_value})
      {:ok, %Tweet{}}

      iex> update_tweet(tweet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_tweet(Tweet.t(), map()) :: {:ok, Tweet.t()} | {:error, Ecto.Changeset.t()}
  def update_tweet(%Tweet{} = tweet, attrs) do
    tweet
    |> Tweet.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, tweet} ->
        {:ok, preload(tweet, force: true)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Deletes a tweet.

  ## Examples

      iex> delete_tweet(tweet)
      {:ok, %Tweet{}}

      iex> delete_tweet(tweet)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_tweet(Tweet.t()) :: {:ok, Tweet.t()} | {:error, Ecto.Changeset.t()}
  def delete_tweet(%Tweet{} = tweet) do
    Repo.delete(tweet, stale_error_field: :id)
  end

  @doc """
  Like a tweet.

  ## Examples

      iex> like_tweet(tweet, user)
      {:ok, %Tweet{}}

      iex> like_tweet(tweet, user)
      {:error, :already_liked}
  """
  @spec like_tweet(Tweet.t(), User.t()) :: {:ok, Tweet.t()} | {:error, :already_liked}
  def like_tweet(%Tweet{} = tweet, %User{} = user) do
    %{tweet_id: tweet.id, user_id: user.id}
    |> Like.changeset()
    |> Repo.insert()
    |> case do
      {:ok, _like} ->
        {:ok, preload(tweet, force: true)}

      {:error, %Ecto.Changeset{errors: [tweet_id: {"has already been taken", _}]}} ->
        {:error, :already_liked}

      {:error, %Ecto.Changeset{errors: [user_id: {"has already been taken", _}]}} ->
        {:error, :already_liked}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Unlike a tweet.

  ## Examples

      iex> unlike_tweet(tweet, user)
      {:ok, %Tweet{}}

      iex> unlike_tweet(tweet, user)
      {:error, %Ecto.Changeset{}}
  """
  @spec unlike_tweet(Tweet.t(), User.t()) :: {:ok, Tweet.t()} | {:error, Ecto.Changeset.t()}
  def unlike_tweet(%Tweet{} = tweet, %User{} = user) do
    with l when not is_nil(l) <- Repo.get_by(Like, tweet_id: tweet.id, user_id: user.id),
         {:ok, _} <- Repo.delete(l) do
      {:ok, preload(tweet, force: true)}
    else
      nil ->
        {:error, :not_found}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Lists all tweets liked by user

  ## Examples

      iex> get_likes(user)
      [%Tweet{}, ...]
  """
  @spec list_liked_tweets(User.t()) :: [Tweet.t()]
  def list_liked_tweets(%User{} = user) do
    from(t in Tweet,
      join: l in Like,
      on: l.tweet_id == t.id,
      where: l.user_id == ^user.id,
      order_by: [desc: l.inserted_at]
    )
    |> Repo.all()
    |> preload()
  end

  @doc """
  Gets user's feed.

  ## Examples

      iex> get_feed(user)
      [%Tweet{}, ...]
  """
  @spec get_feed(User.t()) :: [Tweet.t()]
  def get_feed(%User{} = user) do
    followees =
      user
      |> Repo.preload([:followees], force: true)
      |> Map.get(:followees)
      |> Enum.map(& &1.id)

    from(t in Tweet,
      where: t.author_id in ^followees,
      order_by: [desc: t.inserted_at]
    )
    |> Repo.all()
    |> preload()
  end

  def descendants(tweet, depth \\ 1000) do
    from(t in Tweet,
      where:
        t.id in fragment(
          """
          WITH RECURSIVE replies_tree AS (
            SELECT id, 0 AS depth FROM tweets WHERE id = ?
          UNION ALL
            SELECT tweets.id, replies_tree.depth + 1 FROM tweets
              JOIN replies_tree ON tweets.reply_to_id = replies_tree.id
              WHERE depth + 1 < ?
          )
          SELECT id FROM replies_tree
          """,
          type(^tweet.id, :binary_id),
          type(^depth, :integer)
        )
    )
  end
end
