defmodule Twitter.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :follower_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
