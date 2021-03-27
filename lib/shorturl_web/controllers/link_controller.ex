defmodule ShorturlWeb.LinkController do
  use ShorturlWeb, :controller

  alias Shorturl.Links
  alias Shorturl.Links.Link

  def new(conn, _params) do
    changeset = Links.change_link(%Link{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"link" => link_params}) do
    case create_link(link_params) do
      {:ok, link} ->
        conn
        |> put_flash(:info, "Link created successfully.")
        |> redirect(to: Routes.link_path(conn, :show, link))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def redirect_to(conn, %{"id" => id}) do
    try do
      link = Links.get_link!(id)
      # Start task for side-effect
      Task.start(fn -> update_visits_for_link(link) end)
      redirect(conn, external: link.url)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_flash(:error, "Invalid link")
        |> redirect(to: Routes.link_path(conn, :new))
    end
  end

  def show(conn, %{"id" => id}) do
    try do
      link = Links.get_link!(id)
      domain = System.get_env("APP_BASE_URL") || nil
      render(conn, "show.html", link: link, domain: domain)
    rescue
      Ecto.NoResultsError ->
        conn
        |> put_flash(:error, "Invalid link")
        |> redirect(to: Routes.link_path(conn, :new))
    end
  end

  defp create_link(link_params) do
    key = random_string(8)
    params = Map.put(link_params, "id", key)

    try do
      case Links.create_link(params) do
        {:ok, link} ->
          {:ok, link}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:error, changeset}
      end
    rescue
      Ecto.ConstraintError ->
        create_link(params)
    end
  end

  defp update_visits_for_link(link) do
    Links.update_link(link, %{visits: link.visits + 1})
  end

  defp random_string(string_length) do
    :crypto.strong_rand_bytes(string_length)
    |> Base.url_encode64()
    |> binary_part(0, string_length)
  end
end
