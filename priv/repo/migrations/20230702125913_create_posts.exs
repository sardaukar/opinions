defmodule Opinions.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :text
      add :body, :text
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :parent_id, references(:posts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:posts, [:author_id])
    create index(:posts, [:parent_id])
  end
end
