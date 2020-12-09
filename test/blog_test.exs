defmodule BlogTest do
  use ExUnit.Case, async: true
  use Plug.Test
  doctest Blog.Plug

  test "functions properly" do
    conn = Blog.Plug.call(conn(:get, "/"), nil)
    assert conn.status == 200
  end

  test "gathers a collection of posts"
  test "fetches a single post"
  test "handles a zero-post fetch properly"
end
