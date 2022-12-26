defmodule Twitter.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :password_hash, :string

    has_many :tweets, Twitter.Tweets.Tweet, foreign_key: :author_id

    many_to_many :followers, Twitter.Users.User,
      join_through: "subscriptions",
      join_keys: [user_id: :id, follower_id: :id]

    many_to_many :followees, Twitter.Users.User,
      join_through: "subscriptions",
      join_keys: [follower_id: :id, user_id: :id]

    many_to_many :likes, Twitter.Tweets.Tweet,
      join_through: "likes",
      join_keys: [user_id: :id, tweet_id: :id]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :password])
    |> validate_required([:name, :password])
  end
end
