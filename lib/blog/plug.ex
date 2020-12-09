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
    case conn.method do
      # Get posts
      "GET" ->
        case conn.path_info do
          ["api", "v0", "posts", idx] ->
            IO.puts("/#{idx}")
            date = DateTime.utc_now()

            case Integer.parse(idx) do
              # Fetch a post
              {idx_proper, _binary} when idx_proper >= 0 ->
                {:ok, json} =
                  Jason.encode(%{
                    "head" => "This is post ##{idx_proper}",
                    "body" => "Hello world",
                    "posted_on" => DateTime.to_string(date)
                  })

                conn
                |> put_resp_content_type("application/json")
                |> send_resp(200, json)

              # This request is malformed but it does have a post ID
              _ ->
                {:ok, json} =
                  Jason.encode(%{
                    "e" => "invalid"
                  })

                conn
                |> put_resp_content_type("application/json")
                |> send_resp(400, json)
            end

          # Fetch many posts
          ["api", "v0", "posts"] ->
            IO.puts("/")
            {:ok, json} = Jason.encode([])

            conn
            |> put_resp_content_type("application/json")
            |> send_resp(200, json)
        end

      # Post a post
      "POST" ->
        {:ok, json} =
          Jason.encode(%{
            "e" => "unimplemented"
          })

        conn
        |> put_resp_content_type("application/json")
        |> send_resp(501, json)
    end
  end
end
