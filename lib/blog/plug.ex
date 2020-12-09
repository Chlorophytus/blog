defmodule Blog.Plug do
  @moduledoc """
  A simple JSON based blog backbone
  """
  import Plug.Conn

  @spec init(any) :: any
  def init(options) do
    # initialize options
    options
  end

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, _opts) do
    {:ok, json} = Jason.encode(%{"head" => "Hello world", "body" => "Hello world"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, json)
  end
end
