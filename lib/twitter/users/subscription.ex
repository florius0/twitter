defmodule Twitter.Users.Subscription do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "subscriptions" do
    belongs_to :followee, Twitter.Users.User
    belongs_to :follower, Twitter.Users.User

    timestamps()
  end

  @doc false
  def changeset(subscription \\ %__MODULE__{}, attrs) do
    subscription
    |> cast(attrs, [:followee_id, :follower_id])
    |> validate_required([:followee_id, :follower_id])
    |> unique_constraint([:followee_id, :follower_id])
  end
end
