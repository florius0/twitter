defmodule Twitter.Tweets.Like do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "likes" do
    belongs_to(:user, Twitter.Users.User)
    belongs_to(:tweet, Twitter.Tweets.Tweet)

    timestamps()
  end

  @doc false
  def changeset(like \\ %__MODULE__{}, attrs) do
    like
    |> cast(attrs, [:user_id, :tweet_id])
    |> validate_required([:user_id, :tweet_id])
    |> unique_constraint([:user_id, :tweet_id])
  end
end
