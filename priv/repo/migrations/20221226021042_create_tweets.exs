defmodule Twitter.Repo.Migrations.CreateTweets do
  use Ecto.Migration

  def change do
    create table(:tweets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :text, :text
      add :author, references(:users, on_delete: :delete_all, type: :binary_id)
      add :reply_to, references(:tweets, on_delete: :delete_al, type: :binary_id)

      timestamps()
    end

    create index(:tweets, [:author])
    create index(:tweets, [:reply_to])
  end
end
