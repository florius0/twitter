defmodule Twitter.Tweets.Tweet do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "tweets" do
    field :text, :string

    belongs_to :author, Twitter.Users.User, foreign_key: :author_id
    belongs_to :reply_to, Twitter.Tweets.Tweet, foreign_key: :reply_to_id

    many_to_many :likes, Twitter.Users.User,
      join_through: "likes",
      join_keys: [tweet_id: :id, user_id: :id]

    has_many :replies, Twitter.Tweets.Tweet, foreign_key: :reply_to_id

    timestamps()
  end

  @doc false
  def changeset(tweet \\ %__MODULE__{}, attrs) do
    tweet
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
