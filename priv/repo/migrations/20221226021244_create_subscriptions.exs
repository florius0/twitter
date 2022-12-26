defmodule Twitter.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :follower_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:subscriptions, [:user_id])
    create index(:subscriptions, [:follower_id])

    create unique_index(:subscriptions, [:user_id, :follower_id])
  end
end
