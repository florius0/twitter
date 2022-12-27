defmodule Twitter.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :name, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string, redact: true

    has_many :tweets, Twitter.Tweets.Tweet, foreign_key: :author_id

    many_to_many :followers, Twitter.Users.User,
      join_through: "subscriptions",
      join_keys: [followee_id: :id, follower_id: :id]

    many_to_many :followees, Twitter.Users.User,
      join_through: "subscriptions",
      join_keys: [follower_id: :id, followee_id: :id]

    many_to_many :likes, Twitter.Tweets.Tweet,
      join_through: "likes",
      join_keys: [user_id: :id, tweet_id: :id]

    timestamps()
  end

  @doc false
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:name, :password_hash, :password, :password_confirmation])
    |> validate_length(:name, min: 3, max: 20)
    |> validate_length(:password, min: 8, max: 20)
    |> validate_confirmation(:password)
    |> hash_password()
    |> unique_constraint(:name)
    |> validate_required([:name, :password_hash])
  end

  defp hash_password(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        changeset
        |> put_change(:password_hash, Bcrypt.hash_pwd_salt(password))
        |> put_change(:password, nil)
        |> put_change(:password_confirmation, nil)

      _ ->
        changeset
    end
  end
end
