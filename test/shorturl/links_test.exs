defmodule Shorturl.LinksTest do
  use Shorturl.DataCase

  alias Shorturl.Links

  describe "links" do
    alias Shorturl.Links.Link

    @valid_attrs %{id: "jfi6kf9h", url: "https://domain.com", visits: 0}
    @update_attrs %{visits: 1}
    @invalid_attrs %{url: nil}
    @empty_url_attrs %{id: "jfi6kf9h", url: nil, visits: 0}
    @invalid_url_attrs %{id: "jfi6kf9h", url: "aklsdasdf", visits: 0}
    @duplicated_id_attrs %{id: "jfi6kf9h", url: "https://lofy.io", visits: 0}
    @duplicated_url_attrs %{id: "12345678", url: "https://domain.com", visits: 0}

    def link_fixture(attrs \\ %{}) do
      {:ok, link} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Links.create_link()

      link
    end

    test "create_link/1 with valid data creates a link" do
      assert {:ok, %Link{} = link} = Links.create_link(@valid_attrs)
      assert link.url == "https://domain.com"
      assert link.visits == 0
    end

    test "create_link/1 with invalid duplicated url" do
      {:ok, %Link{}} = Links.create_link(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(@duplicated_url_attrs)
    end

    test "create_link/1 with invalid duplicated id" do
      {:ok, %Link{}} = Links.create_link(@valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Links.create_link(@duplicated_id_attrs)
    end

    test "get_link!/1 return the link with given id via cache" do
      link = link_fixture()
      assert @valid_attrs = Links.get_link!(link.id) # via db
      assert @valid_attrs = Links.get_link!(link.id) # via cache
    end

    test "get_link_no_cache!/1 returns the link with given id" do
      link = link_fixture()
      assert Links.get_link_no_cache!(link.id) == link
    end

    test "get_link_no_cache!/1 return nil" do
      assert Links.get_link_no_cache("??") == nil
    end

    test "get_link_no_cache!/1 return link struct" do
      link = link_fixture()
      assert Links.get_link_no_cache(link.id) == link
    end

    test "get_link_by_url return nil" do
      assert Links.get_link_by_url("??") == nil
    end

    test "get_link_by_url return link struct" do
      link = link_fixture()
      assert Links.get_link_by_url(link.url) == link
    end

    test "create_link/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Links.create_link(@invalid_attrs)
    end

    test "update_link/2 with valid data updates the link" do
      link = link_fixture()
      assert {:ok, %Link{} = link} = Links.update_link(link, @update_attrs)
      assert link.visits == 1
    end

    test "update_link/2 with invalid data returns error changeset" do
      link = link_fixture()
      assert {:error, %Ecto.Changeset{}} = Links.update_link(link, @invalid_attrs)
      assert link == Links.get_link_no_cache!(link.id)
    end

    test "change_link/1 returns a link changeset" do
      link = link_fixture()
      assert %Ecto.Changeset{} = Links.change_link(link)
    end

    test "is_taken/2 with id taken" do
      {:ok, %Link{}} = Links.create_link(@valid_attrs)
      {:error, changeset} = Links.create_link(@duplicated_id_attrs)
      assert Links.is_taken?(changeset, :id) == true
    end

    test "is_taken/2 with url taken" do
      {:ok, %Link{}} = Links.create_link(@valid_attrs)
      {:error, changeset} = Links.create_link(@duplicated_url_attrs)
      assert Links.is_taken?(changeset, :url) == true
    end

    test "is_url_invalid with empty url" do
      {:error, changeset} = Links.create_link(@empty_url_attrs)
      assert Links.is_url_invalid?(changeset) == true
    end

    test "is_url_invalid with invalid url" do
      {:error, changeset} = Links.create_link(@invalid_url_attrs)
      assert Links.is_url_invalid?(changeset) == true
    end

  end
end
