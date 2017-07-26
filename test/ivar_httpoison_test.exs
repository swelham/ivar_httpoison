defmodule Ivar.HttpoisonTest do
  use ExUnit.Case
  doctest Ivar.HTTPoison

  import Ivar.HTTPoison.TestMacros

  setup do
    bypass = Bypass.open

    {:ok, bypass: bypass}
  end

  test "execute/1 should send minimal empty request", %{bypass: bypass} do
    methods = [:get, :post, :patch, :put, :delete]

    for method <- methods do
      Bypass.expect bypass, fn conn ->
        assert conn.method == method_type(method)
        assert conn.host == "localhost"
        assert conn.port == bypass.port

        Plug.Conn.send_resp(conn, 200, "")
      end

      {:ok, result} =
        Ivar.new(method, test_url(bypass))
        |> Ivar.send
      
      assert result.status_code == 200
    end
  end

  test "execute/1 should send request with body", %{bypass: bypass} do
    methods = [:post, :patch, :put]

    for method <- methods do
      Bypass.expect bypass, fn conn ->
        {:ok, body, _} = Plug.Conn.read_body(conn)

        assert has_header(conn, {"content-type", "application/x-www-form-urlencoded"})
        assert body == "test=123"

        Plug.Conn.send_resp(conn, 200, "")
      end

      {:ok, result} =
        Ivar.new(method, test_url(bypass))
        |> Ivar.Body.put(%{test: 123}, :url_encoded)
        |> Ivar.send
      
      assert result.status_code == 200
    end
  end

  test "execute/1 should send request with headers", %{bypass: bypass} do
    methods = [:get, :post, :patch, :put, :delete]

    for method <- methods do
      Bypass.expect bypass, fn conn ->
        assert has_header(conn, {"x-test", "123"})
        assert has_header(conn, {"x-abc", "xyz"})

        Plug.Conn.send_resp(conn, 200, "")
      end

      {:ok, result} =
        Ivar.new(method, test_url(bypass))
        |> Ivar.Headers.put("x-test", "123")
        |> Ivar.Headers.put("x-abc", "xyz")
        |> Ivar.send
      
      assert result.status_code == 200
    end
  end

  test "execute/1 should send request with bearer auth header", %{bypass: bypass} do
    methods = [:get, :post, :patch, :put, :delete]

    for method <- methods do
      Bypass.expect bypass, fn conn ->
        assert has_header(conn, {"authorization", "Bearer some.token"})

        Plug.Conn.send_resp(conn, 200, "")
      end

      {:ok, result} =
        Ivar.new(method, test_url(bypass))
        |> Ivar.Auth.put("some.token", :bearer)
        |> Ivar.send
      
      assert result.status_code == 200
    end
  end

  test "execute/1 should send request with basic auth header", %{bypass: bypass} do
    methods = [:get, :post, :patch, :put, :delete]

    for method <- methods do
      Bypass.expect bypass, fn conn ->
        assert has_header(conn, {"authorization", "Basic dXNlcm5hbWU6cGFzc3dvcmQ="})
        
        Plug.Conn.send_resp(conn, 200, "")
      end

      {:ok, result} =
        Ivar.new(method, test_url(bypass))
        |> Ivar.Auth.put({"username", "password"}, :basic)
        |> Ivar.send
      
      assert result.status_code == 200
    end
  end

  test "execute/1 should send request with files attached", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)
      
      assert body != nil
      assert has_header(conn, {"content-length", "10322"})
      assert has_multipart_header(conn)
      
      Plug.Conn.send_resp(conn, 200, "")
    end
    
    file_data = File.read!("test/fixtures/elixir.png")
    
    {:ok, result} =
      Ivar.new(:post, test_url(bypass))
      |> Ivar.Files.put({"file", file_data, "elixir.png", "png"})
      |> Ivar.send
      
    assert result.status_code == 200
  end

  test "execute/1 should send request with files and body", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      {:ok, body, _} = Plug.Conn.read_body(conn)

      assert body != nil
      assert has_header(conn, {"content-length", "10481"})
      assert has_multipart_header(conn)
      
      Plug.Conn.send_resp(conn, 200, "")
    end
    
    file_data = File.read!("test/fixtures/elixir.png")
    
    {:ok, result} =
      Ivar.new(:post, test_url(bypass))
      |> Ivar.Body.put(%{test: "data"}, :url_encoded)
      |> Ivar.Files.put({"file", file_data, "elixir.png", "png"})
      |> Ivar.send
      
    assert result.status_code == 200
  end

  test "execute/1 should set query string", %{bypass: bypass} do
    Bypass.expect bypass, fn conn ->
      assert conn.query_string == "my=query"

      Plug.Conn.send_resp(conn, 200, "")
    end

    {:ok, result} =
      Ivar.new(:get, test_url(bypass))
      |> Ivar.put_query_string([my: "query"])
      |> Ivar.send

    assert result.status_code == 200
  end

  defp test_url(%{port: port}), do: "http://localhost:#{port}/"

  defp method_type(:get),     do: "GET"
  defp method_type(:post),    do: "POST"
  defp method_type(:put),     do: "PUT"
  defp method_type(:patch),   do: "PATCH"
  defp method_type(:delete),  do: "DELETE"
end
