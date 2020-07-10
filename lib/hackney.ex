defmodule Superbet.Hackney do
  @moduledoc """
  Hackney wrapper
  """

  @max_body_len 10_000_000

  def get(url, request, params \\ [])
      when is_binary(url) and is_binary(request) and is_list(params) do
    headers = Keyword.get(params, :headers, [])
    options = Keyword.get(params, :options, [])

    :hackney.get(url, headers, request, options)
    |> process_response()
  end

  # Helpers

  defp process_response(resp) do
    case resp do
      {:ok, status, headers, body_ref} when status in 200..299 ->
        case read_body(@max_body_len, body_ref, <<>>) do
          {:ok, body} -> {:ok, headers, body}
          {:error, reason} -> {:error, reason}
        end

      {:ok, status, _headers, body} ->
        # we got some other http status, make it an error
        # body may require parsing (in case if json error message is expected)
        {:error, {:hackney, status, body}}

      {:error, reason} ->
        # there was some other error, e.g. server is not available
        {:error, {:hackney, reason}}
    end
  end

  def read_body(max_length, body_ref, acc) when max_length > byte_size(acc) do
    case :hackney.stream_body(body_ref) do
      {:ok, data} -> read_body(max_length, body_ref, acc <> data)
      :done -> {:ok, acc}
      {:error, reason} -> {:error, reason}
    end
  end
end
