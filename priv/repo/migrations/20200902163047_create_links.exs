defmodule Shorturl.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links, primary_key: false) do
      add :id, :string, size: 8, primary_key: true
      add :url, :text, null: false
      add :visits, :integer, default: 0

      timestamps()
    end
  end
end
