require Logger

defmodule Blog.Authenticate do
  @moduledoc """
  Authentication to POST a blog entry
  """
  @spec init :: :ok | {:error, atom}
  def init() do
    Logger.info("writing the initial key...")
    File.mkdir(Application.app_dir(:blog, ["keys"]))

    File.write(
      Application.app_dir(:blog, ["keys", "mac.sec"]),
      :crypto.hash(:sha3_512, [
        Integer.to_string(:erlang.unique_integer(), 16),
        ?:,
        Integer.to_string(:os.system_time(), 16),
        ?:,
        :crypto.strong_rand_bytes(64)
      ])
      |> Base.url_encode64()
    )
  end

  @spec sign(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | byte,
              binary | []
            )
        ) :: any
  def sign(message) do
    Logger.info("signing a HMAC...")

    {:ok, init_key64} = File.read(Application.app_dir(:blog, ["keys", "mac.sec"]))

    {:ok, init_key} = init_key64 |> Base.url_decode64()

    :crypto.mac(:hmac, :sha3_512, init_key, message)
  end

  @spec verify(
          binary
          | maybe_improper_list(
              binary | maybe_improper_list(any, binary | []) | byte,
              binary | []
            ),
          any,
          any
        ) :: :error | {:ok, binary}
  def verify(message, hmac, token) do
    Logger.info("verifying a HMAC...")

    {:ok, init_key64} = File.read(Application.app_dir(:blog, ["keys", "mac.sec"]))

    {:ok, init_key} = init_key64 |> Base.url_decode64()

    {:ok, totp_key} = File.read(Application.app_dir(:blog, ["keys", "otp.sec"]))

    next_ir_key = :crypto.mac(:hmac, :sha3_512, init_key, message)

    cond do
      hmac == next_ir_key and :pot.valid_totp(token, totp_key) ->
        next_key =
          :crypto.hash(:sha3_512, [
            Integer.to_string(:erlang.unique_integer(), 16),
            ?:,
            Integer.to_string(:os.system_time(), 16),
            ?:,
            :crypto.strong_rand_bytes(64)
          ])
          |> Base.url_encode64()

        File.write(
          Application.app_dir(:blog, ["keys", "mac.sec"]),
          next_key
        )

        Logger.info("...HMAC PASS")
        {:ok, next_key}

      true ->
        Logger.info("...HMAC FAIL")
        :error
    end
  end
end
