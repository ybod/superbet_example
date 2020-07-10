defmodule Superbet do
  @moduledoc """
  Documentation for `Superbet`.
  """

  alias Superbet.Hackney

  @req_headers [{"Accept", "application/json"}, {"Accept-Charset", "UTF-8"}, {"Accept-encoding", "deflate"}]
  @req_options [{:recv_timeout, 30_000}]

  @host "https://offer1.superbet.ro"

  def get_matches_by_id(match_id) when is_binary(match_id) do
    url = "#{@host}/matches/getMatchesByIds?matchIds=#{match_id}"

    with {:ok, headers, resp_body} <- Hackney.get(url, "", headers: @req_headers, options: @req_options),
         uncompresses_body = uncompress_body(headers, resp_body),
         {:ok, json_resp} <- Jason.decode(uncompresses_body),
         {:ok, data} <- get_data(json_resp) do
      {:ok, data}
    end
  end

  # helpers
  defp uncompress_body(headers, resp_body) when is_list(headers) and is_binary(resp_body) do
    if has_deflate_ecoding_header?(headers) do
      try do
        # actually deflate should be handled via :zlib.unzip
        :zlib.uncompress(resp_body)
      rescue
        _ -> resp_body
      end
    else
      resp_body
    end
  end

  defp has_deflate_ecoding_header?(headers) when is_list(headers) do
    Enum.any?(headers, fn {k, v} -> String.downcase(k) == "content-encoding" and String.downcase(v) == "deflate" end)
  end

  defp get_data(%{"error" => false, "data" => data}) when is_list(data), do: {:ok, data}
  defp get_data(json_resp), do: {:error, {"unexpected response structure #{inspect(json_resp)}"}}
end
