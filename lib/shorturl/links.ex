defmodule Shorturl.Links do

  import Ecto.Query, warn: false
  alias Shorturl.{Cache, Repo}
  alias Shorturl.Links.Link
  alias Ecto.Changeset

  @cache_server Application.get_env(:shorturl, :link_cache_name)

  def get_link_no_cache!(id), do: Repo.get!(Link, id)

  @doc """
  select * by id, return nil or %Link{}
  """
  def get_link_no_cache(id), do: Repo.get(Link, id)


  @doc """
  select * by id, return nil or %Link{}
  it will check cache first. if there is a hit return the link, else do the db with put cache operaiton
  """
  def get_link!(id) do
    case Cache.get(@cache_server, id) do
      %Link{} = link -> link
      nil -> get_link_db!(id)
    end
  end

  defp get_link_db!(id) do
    link = Repo.get!(Link, id)
    Cache.put(@cache_server, id, link)
    link
  end

  @doc """
  select * by url
  return nil or %Link{}
  """
  def get_link_by_url(url) , do: Repo.get_by(Link, url: url)

  def create_link(attrs \\ %{}) do
    %Link{}
    |> Link.changeset(attrs)
    |> Repo.insert()
  end

  def update_link(%Link{} = link, attrs) do
    link
    |> Link.changeset(attrs)
    |> Repo.update()
  end

  def delete_all_old() do
    from(l in Link, where: l.updated_at < ago(7, "day")) |> Repo.delete_all()
  end

  def change_link(%Link{} = link, attrs \\ %{}) do
    Link.changeset(link, attrs)
  end

  @doc """
  input: changeset, the atom of column name
  output: is the column has been taken or not according to the changeset
  """
  def is_taken?(%Changeset{} = changeset, name) do
    case changeset.errors[name] do
      {"has already been taken", _opt} -> true
      _ -> false
    end
  end

  @doc """
  input, changeset
  output, is the url invalid or not according to the changeset
  """
  def is_url_invalid?(%Changeset{} = changeset) do
    case changeset.errors[:url] do
      {"can't be blank", _opt} -> true
      {"Please enter valid url!", _opt} -> true
      _ -> false
    end
  end
end
