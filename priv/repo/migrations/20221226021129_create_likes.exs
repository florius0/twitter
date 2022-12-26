defmodule Twitter.Repo.Migrations.CreateLikes do
  use Ecto.Migration

  def change do
    add table(:likes) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :tweet_id, references(:tweets, on_delete: :delete_all)

      timestamps()
    end

    create index(:likes, [:user_id])
    create index(:likes, [:tweet_id])

    create unique_index(:likes, [:user_id, :tweet_id])
  end
end
