defmodule ShorturlWeb.LinkControllerTest do
  use ShorturlWeb.ConnCase

  alias Shorturl.Links

  @create_attrs %{url: "https://domain.com"}
  @invalid_attrs %{url: nil, visits: nil}

  def fixture(:link) do
    {:ok, link} = Links.create_link(@create_attrs)
    link
  end

  describe "new link" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.link_path(conn, :new))
      assert html_response(conn, 200) =~ "Short Link"
    end
  end

  describe "create link" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.link_path(conn, :create), link: @create_attrs)
      %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.link_path(conn, :show, id)

      conn = get(conn, Routes.link_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Link information"
    end

    test "redirect to the same shortened url by passing the same url", %{conn: conn} do
      conn = post(conn, Routes.link_path(conn, :create), link: @create_attrs)
      %{id: id_1} = redirected_params(conn)
      conn = post(conn, Routes.link_path(conn, :create), link: @create_attrs)
      %{id: id_2} = redirected_params(conn)
      assert id_1 =~ id_2
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.link_path(conn, :create), link: @invalid_attrs)
      assert html_response(conn, 200) =~ "Short Link"
    end
  end

  describe "shortened url" do
    test "redirects to original url", %{conn: conn} do
      conn = get(conn, Routes.link_path(conn, :redirect_to, "dkljd34g"))
      assert html_response(conn, 302)
    end
  end
end
